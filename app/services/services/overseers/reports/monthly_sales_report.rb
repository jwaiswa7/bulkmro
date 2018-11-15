class Services::Overseers::Reports::MonthlySalesReport < Services::Overseers::Reports::BaseReport
  def call
    call_base

    @data = OpenStruct.new(
        {
            geographies: [],
            entries: {}
        }
    )

    start_at = Date.new(2018, 04, 01)
    end_at = Date.today.end_of_day

    ActiveRecord::Base.default_timezone = :utc

    inquiries = Inquiry.includes({sales_quotes: [{sales_quote_rows: :supplier}]}).where(:created_at => start_at.beginning_of_month..end_at.end_of_month)
    sales_orders = SalesOrder.where(:created_at => start_at.beginning_of_month..end_at.end_of_month).where('sales_orders.status = ? OR sales_orders.legacy_request_status = ?', SalesOrder.statuses[:'Approved'], SalesOrder.statuses[:'Approved'])

    inquiry_groups = inquiries.group_by_month(:created_at, default_value: nil).count
    sales_order_groups = sales_orders.group_by_month(:created_at, default_value: nil).count

    months = inquiry_groups.keys

    months.each do |month|
      @data.entries[month.to_s] = { :inquiry_count => 0, :sales_order_count => 0, :total => 0 }

      @data.entries[month.to_s][:inquiry_count] = inquiry_groups[month]
      @data.entries[month.to_s][:sales_order_count] = sales_order_groups[month]
      @data.entries[month.to_s][:total] = sales_orders.where(:created_at => month.to_date.beginning_of_month..month.to_date.end_of_month).map{|s| s.calculated_total}.inject(0){|sum,x| sum + x }.to_f.round(2)
      # where(:created_at => datetime.beginning_of_month..datetime.end_of_month)
    end

    ActiveRecord::Base.default_timezone = :local

    data
  end
end