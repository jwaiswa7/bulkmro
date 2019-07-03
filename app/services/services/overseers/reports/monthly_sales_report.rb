class Services::Overseers::Reports::MonthlySalesReport < Services::Overseers::Reports::BaseReport
  def call
    call_base
    @current_overseer

    @data = OpenStruct.new(
      geographies: [],
      entries: {}
    )

    start_at = Date.new(2018, 04, 01)
    end_at = Date.today.end_of_day

    ActiveRecord::Base.default_timezone = :utc

    if @current_overseer.present? && !@current_overseer.allow_inquiries?
      inquiries = Inquiry.includes(:products).where(created_at: start_at.beginning_of_month..end_at.end_of_month).where('inside_sales_owner_id = ? or outside_sales_owner_id = ? or procurement_operations_id = ?', @current_overseer.id, @current_overseer.id, @current_overseer.id)
      sales_orders = SalesOrder.without_cancelled.includes([rows: :sales_quote_row]).joins(:inquiry).where(created_at: start_at.beginning_of_month..end_at.end_of_month).where('sales_orders.status = ? OR sales_orders.legacy_request_status = ?', SalesOrder.statuses[:'Approved'], SalesOrder.statuses[:'Approved']).where('inquiries.inside_sales_owner_id = ? or inquiries.outside_sales_owner_id = ? or inquiries.procurement_operations_id = ?', @current_overseer.id, @current_overseer.id, @current_overseer.id)
    else
      inquiries = Inquiry.includes(:products).where(created_at: start_at.beginning_of_month..end_at.end_of_month)
      sales_orders = SalesOrder.without_cancelled.includes([rows: :sales_quote_row]).where(created_at: start_at.beginning_of_month..end_at.end_of_month).where('sales_orders.status = ? OR sales_orders.legacy_request_status = ? ', SalesOrder.statuses[:'Approved'], SalesOrder.statuses[:'Approved'])
    end


    inquiry_groups = inquiries.group_by_month(:created_at, default_value: nil).count
    sales_order_groups = sales_orders.group_by_month(:created_at, default_value: nil).count
    months = inquiry_groups.keys.reverse

    summary = { inquiry_count: 0, sales_order_count: 0, total: 0, products_count: 0, product_quantities: 0 }

    months.each do |month|
      @data.entries[month.to_s] = { inquiry_count: 0, sales_order_count: 0, total: 0, products_count: 0, product_quantities: 0 }

      products = inquiries.where(created_at: month.to_date.beginning_of_month..month.to_date.end_of_month).map{ |i| i.products.pluck(:id) }.flatten.uniq
      orders = sales_orders.where(created_at: month.to_date.beginning_of_month..month.to_date.end_of_month)

      @data.entries[month.to_s][:inquiry_count] = inquiry_groups[month].present? ? inquiry_groups[month] : 0
      @data.entries[month.to_s][:sales_order_count] = sales_order_groups[month].present? ? sales_order_groups[month] : 0
      @data.entries[month.to_s][:total] = orders.map{ |s| s.calculated_total }.inject(0){ |sum, x| sum + x }.to_f.round(2)
      @data.entries[month.to_s][:products_count] = products.size
      @data.entries[month.to_s][:product_quantities] = orders.map{ |o| o.total_quantities }.inject(0){ |sum, x| sum + x }.to_f

      summary[:inquiry_count] = summary[:inquiry_count] + @data.entries[month.to_s][:inquiry_count]
      summary[:sales_order_count] = summary[:sales_order_count] + @data.entries[month.to_s][:sales_order_count]
      summary[:total] = summary[:total] + @data.entries[month.to_s][:total]
      summary[:products_count] = summary[:products_count] + @data.entries[month.to_s][:products_count]
      summary[:product_quantities] = summary[:product_quantities] + @data.entries[month.to_s][:product_quantities]
    end

    @data.entries[:total] = summary

    ActiveRecord::Base.default_timezone = :local
    Rails.cache.write('monthly_sales_report_data', @data, expires_in: 1.hour)

    @data
  end
end
