class Services::Overseers::Dashboards::Admin < Services::Shared::BaseService
  def initialize
  end

  def call

    @data = OpenStruct.new(
        {
            entries: {}
        }
    )

    start_at = Date.new(2018, 10, 01)
    end_at = Date.today.end_of_day

    ActiveRecord::Base.default_timezone = :utc

    inquiries = Inquiry.includes(:products).where(:created_at => start_at.beginning_of_month..end_at.end_of_month)
    sales_quotes = SalesQuote.includes(:rows).where(:created_at => start_at.beginning_of_month..end_at.end_of_month)
    sales_orders = SalesOrder.includes(:rows).where(:mis_date => start_at.beginning_of_month..end_at.end_of_month).where('sales_orders.status = ? OR sales_orders.legacy_request_status = ?', SalesOrder.statuses[:'Approved'], SalesOrder.statuses[:'Approved'])
    purchase_orders = PurchaseOrder.includes(:rows).where(:created_at => start_at.beginning_of_month..end_at.end_of_month)
    sales_invoices = SalesInvoice.includes(:rows).where(:created_at => start_at.beginning_of_month..end_at.end_of_month)

    inquiry_groups = inquiries.group_by_month(:created_at, default_value: nil).count
    sales_quotes_groups = sales_quotes.group_by_month(:created_at, default_value: nil).count
    sales_order_groups = sales_orders.group_by_month(:mis_date, default_value: nil).count
    purchase_orders_groups = purchase_orders.group_by_month(:created_at, default_value: nil).count
    sales_invoices_groups = sales_invoices.group_by_month(:created_at, default_value: nil).count

    months = inquiry_groups.keys

    months.each do |month|
      @data.entries[month.to_s] = {:inquiry => 0, :sales_quotes => 0, :sales_order => 0, :purchase_order => 0, :sales_invoice => 0}

      @data.entries[month.to_s][:inquiry] = {
          :count => inquiry_groups[month].present? ? inquiry_groups[month] : 0,
          :total => inquiries.where(:created_at => month.to_date.beginning_of_month..month.to_date.end_of_month).where.not(:potential_amount => nil).sum(&:potential_amount)
      }

      @data.entries[month.to_s][:sales_quotes] = {
          :count => sales_quotes_groups[month].present? ? sales_quotes_groups[month] : 0,
          :total => sales_quotes.where(:created_at => month.to_date.beginning_of_month..month.to_date.end_of_month).sum(&:calculated_total)
      }

      @data.entries[month.to_s][:sales_order] = {
          :count => sales_order_groups[month].present? ? sales_order_groups[month] : 0,
          :total => sales_invoices.where(:created_at => month.to_date.beginning_of_month..month.to_date.end_of_month).sum(&:calculated_total)
      }

      @data.entries[month.to_s][:purchase_order] = {
          :count => purchase_orders_groups[month].present? ? sales_order_groups[month] : 0,
          :total => purchase_orders.where(:created_at => month.to_date.beginning_of_month..month.to_date.end_of_month).sum(&:calculated_total)
      }

      @data.entries[month.to_s][:sales_invoice] = {
          :count => sales_invoices_groups[month].present? ? sales_order_groups[month] : 0,
          :total => sales_invoices.where(:created_at => month.to_date.beginning_of_month..month.to_date.end_of_month).sum(&:calculated_total)
      }

    end

    ActiveRecord::Base.default_timezone = :local

    @data
  end

end