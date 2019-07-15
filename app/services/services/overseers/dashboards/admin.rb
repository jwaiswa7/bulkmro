class Services::Overseers::Dashboards::Admin < Services::Shared::BaseService
  def initialize
  end

  def call
    start_at = Date.new(2018, 10, 01).beginning_of_day
    end_at = Date.today.end_of_day

    @data = OpenStruct.new(entries: {}, timestamp: nil)
    ActiveRecord::Base.default_timezone = :utc
    filter_by_dates = start_at.beginning_of_month..end_at.end_of_month
    @data.timestamp = Time.now

    inquiries = Inquiry.includes(:products).where(created_at: filter_by_dates)
    sales_quotes_array = SalesQuote.find_by_sql ['(select *From  sales_quotes sq where sq.created_at = (select max(sales_quotes.created_at) from sales_quotes where sq.inquiry_id = sales_quotes.inquiry_id and sales_quotes.sent_at is not null ) and sq.created_at between ? and ? order by sq.created_at desc) union( select sq.* from sales_quotes as sq left join sales_orders as so on sq.id = so.sales_quote_id where ( so.status = ? or so.legacy_request_status = ? ) and sq.created_at between ? and ?)', start_at.beginning_of_month, end_at.end_of_month, SalesOrder.statuses[:'Approved'], SalesOrder.statuses[:'Approved'], start_at.beginning_of_month, end_at.end_of_month]
    sales_quotes = SalesQuote.includes(:rows).where(id: sales_quotes_array.map(&:id))

    sales_orders = BibleSalesOrder.where(mis_date: filter_by_dates)
    purchase_orders = PurchaseOrder.not_cancelled.includes(:rows).where(created_at: filter_by_dates)
    # sales_invoices = SalesInvoice.not_cancelled.includes(:rows).where(mis_date: filter_by_dates).where.not(sales_order_id: nil).where.not(metadata: nil)
    sales_invoices = BibleInvoice.where(mis_date: filter_by_dates)

    inquiry_groups = inquiries.group_by_month(:created_at, default_value: nil).count
    sales_quotes_groups = sales_quotes.group_by_month(:created_at, default_value: nil).count
    sales_order_groups = sales_orders.group_by_month(:mis_date, default_value: nil).count
    purchase_orders_groups = purchase_orders.group_by_month(:created_at, default_value: nil).count
    sales_invoices_groups = sales_invoices.group_by_month(:mis_date, default_value: nil).count

    months = inquiry_groups.keys

    months.reverse.each do |month|
      @data.entries[month.to_s] = { inquiry: 0, sales_quotes: 0, sales_order: 0, sales_invoice: 0, purchase_order: 0 }

      filter_by_dates = month.to_date.beginning_of_month..month.to_date.end_of_month

      # INQUIRIES
      i = inquiries.where(created_at: filter_by_dates)
      @data.entries[month.to_s][:inquiry] = {
          count: inquiry_groups[month].present? ? inquiry_groups[month] : 0,
          total: i.where.not(potential_amount: nil).sum(&:potential_amount)
      }

      # SALES QUOTES
      sq = sales_quotes.where(created_at: filter_by_dates)

      @data.entries[month.to_s][:sales_quotes] = {
          count: sales_quotes_groups[month].present? ? sales_quotes_groups[month] : 0,
          total: sq.sum(&:calculated_total)
      }

      # SALES ORDERS
      so = BibleSalesOrder.where(mis_date: filter_by_dates)
      # so = sales_orders
      @data.entries[month.to_s][:sales_order] = {
          count: sales_order_groups[month].present? ? sales_order_groups[month] : 0,
          total: so.sum(&:order_total)
          # total: so.sum(&:calculated_total)
      }

      # INVOICES
      si = BibleInvoice.where(mis_date: filter_by_dates)
      # si = sales_invoices
      @data.entries[month.to_s][:sales_invoice] = {
          count: sales_invoices_groups[month].present? ? sales_invoices_groups[month] : 0,
          total: si.sum(&:invoice_total)
      }

      # PURCHASE ORDERS
      po = purchase_orders.where(created_at: filter_by_dates)
      @data.entries[month.to_s][:purchase_order] = {
          count: purchase_orders_groups[month].present? ? purchase_orders_groups[month] : 0,
          total: po.sum(&:calculated_total)
      }
    end
    ActiveRecord::Base.default_timezone = :local
    Rails.cache.write('admin_dashboard_data', @data, expires_in: 35.minutes)
    @data
  end
end