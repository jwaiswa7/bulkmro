class Services::Overseers::Dashboards::Admin < Services::Shared::BaseService
  def initialize
  end

  def call

    @data = OpenStruct.new(
        {
            entries: {}
        }
    )

    start_at = Date.new(2018, 10, 01).beginning_of_day
    end_at = Date.today.end_of_day

    ActiveRecord::Base.default_timezone = :utc

    inquiries = Inquiry.includes(:products).where(:created_at => start_at.beginning_of_month..end_at.end_of_month)
    max_updated_at_for_inquiries = inquiries.order(:updated_at).last.updated_at

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

    months.reverse.each do |month|
      @data.entries[month.to_s] = {:inquiry => 0, :sales_quotes => 0, :sales_order => 0, :sales_invoice => 0, :purchase_order => 0}

      # INQUIRIES
      i = inquiries.where(:created_at => month.to_date.beginning_of_month..month.to_date.end_of_month)
      max_inquiry_updated_at = i.order(:updated_at).last
      cached_inquiry_updated_at = Rails.cache.read("#{month.to_s}-inquiries-updated_at")
      if cached_inquiry_updated_at == nil
        @data.entries[month.to_s][:inquiry] = {
            :count => inquiry_groups[month].present? ? inquiry_groups[month] : 0,
            :total => i.where.not(:potential_amount => nil).sum(&:potential_amount)
        }
        # Create cache
        create_inquiry_cache(month.to_s, @data.entries[month.to_s][:inquiry], max_inquiry_updated_at)
        puts "<----------------NIL------------------->"
      elsif cached_inquiry_updated_at == max_inquiry_updated_at
        @data.entries[month.to_s][:inquiry] = {
            :count => Rails.cache.read("#{month.to_s}-inquiries-count"),
            :total => Rails.cache.read("#{month.to_s}-inquiries-total")
        }
        puts "<----------------Cached------------------->"
      else
        @data.entries[month.to_s][:inquiry] = {
            :count => inquiry_groups[month].present? ? inquiry_groups[month] : 0,
            :total => i.where.not(:potential_amount => nil).sum(&:potential_amount)
        }
        # Create cache
        create_inquiry_cache(month.to_s, @data.entries[month.to_s][:inquiry], max_inquiry_updated_at)
        puts "<----------------Updated Cached------------------->"
      end

      # SALES QUOTES
      sq = sales_quotes.where(:created_at => month.to_date.beginning_of_month..month.to_date.end_of_month)
      max_quote_updated_at = sq.order(:updated_at).last
      cached_quote_updated_at = Rails.cache.read("#{month.to_s}-quotes-updated_at")
      if cached_quote_updated_at == nil
        @data.entries[month.to_s][:sales_quotes] = {
            :count => sales_quotes_groups[month].present? ? sales_quotes_groups[month] : 0,
            :total => sq.sum(&:calculated_total)
        }
        # Create cache
        create_quote_cache(month.to_s, @data.entries[month.to_s][:sales_quotes], max_quote_updated_at)
        puts "<----------------NIL------------------->"
      elsif cached_quote_updated_at == max_quote_updated_at
        @data.entries[month.to_s][:sales_quotes] = {
            :count => Rails.cache.read("#{month.to_s}-quotes-count"),
            :total => Rails.cache.read("#{month.to_s}-quotes-total")
        }
        puts "<----------------Cached------------------->"
      else
        @data.entries[month.to_s][:sales_quotes] = {
            :count => sales_quotes_groups[month].present? ? sales_quotes_groups[month] : 0,
            :total => sq.sum(&:calculated_total)
        }
        # Create cache
        create_quote_cache(month.to_s, @data.entries[month.to_s][:sales_quotes], max_quote_updated_at)
        puts "<----------------Updated Cached------------------->"
      end

      # SALES ORDERS
      so = sales_orders.where(:mis_date => month.to_date.beginning_of_month..month.to_date.end_of_month)
      max_order_updated_at = so.order(:updated_at).last
      cached_order_updated_at = Rails.cache.read("#{month.to_s}-orders-updated_at")
      if cached_order_updated_at == nil
        @data.entries[month.to_s][:sales_order] = {
            :count => sales_order_groups[month].present? ? sales_order_groups[month] : 0,
            :total => so.sum(&:calculated_total)
        }
        # Create cache
        create_order_cache(month.to_s, @data.entries[month.to_s][:sales_order], max_order_updated_at)
        puts "<----------------NIL------------------->"
      elsif cached_order_updated_at == max_order_updated_at
        @data.entries[month.to_s][:sales_order] = {
            :count => Rails.cache.read("#{month.to_s}-order-count"),
            :total => Rails.cache.read("#{month.to_s}-order-total")
        }
        puts "<----------------Cached------------------->"
      else
        @data.entries[month.to_s][:sales_order] = {
            :count => sales_order_groups[month].present? ? sales_order_groups[month] : 0,
            :total => so.sum(&:calculated_total)
        }
        # Create cache
        create_order_cache(month.to_s, @data.entries[month.to_s][:sales_order], max_order_updated_at)
        puts "<----------------Updated Cached------------------->"
      end

      # INVOICES
      si = sales_invoices.where(:created_at => month.to_date.beginning_of_month..month.to_date.end_of_month)
      max_invoice_updated_at = si.order(:updated_at).last
      cached_invoice_updated_at = Rails.cache.read("#{month.to_s}-invoices-updated_at")
      if cached_invoice_updated_at == nil
        @data.entries[month.to_s][:sales_invoice] = {
            :count => sales_invoices_groups[month].present? ? sales_invoices_groups[month] : 0,
            :total => si.sum(&:calculated_total)
        }
        # Create cache
        create_invoice_cache(month.to_s, @data.entries[month.to_s][:sales_invoice], max_invoice_updated_at)
        puts "<----------------NIL------------------->"
      elsif cached_invoice_updated_at == max_invoice_updated_at
        @data.entries[month.to_s][:sales_invoice] = {
            :count => Rails.cache.read("#{month.to_s}-invoices-count"),
            :total => Rails.cache.read("#{month.to_s}-invoices-total")
        }
        puts "<----------------Cached------------------->"
      else
        @data.entries[month.to_s][:sales_invoice] = {
            :count => sales_invoices_groups[month].present? ? sales_invoices_groups[month] : 0,
            :total => si.sum(&:calculated_total)
        }
        # Create cache
        create_invoice_cache(month.to_s, @data.entries[month.to_s][:sales_invoice], max_invoice_updated_at)
        puts "<----------------Updated Cached------------------->"
      end

      # PURCHASE ORDERS
      po = purchase_orders.where(:created_at => month.to_date.beginning_of_month..month.to_date.end_of_month)
      max_purchase_order_updated_at = po.order(:updated_at).last
      cached_purchase_order_updated_at = Rails.cache.read("#{month.to_s}-purchase-orders-updated_at")
      if cached_purchase_order_updated_at == nil
        @data.entries[month.to_s][:purchase_order] = {
            :count => purchase_orders_groups[month].present? ? purchase_orders_groups[month] : 0,
            :total => po.sum(&:calculated_total)
        }
        # Create cache
        create_purchase_order_cache(month.to_s, @data.entries[month.to_s][:purchase_order], max_purchase_order_updated_at)
        puts "<----------------NIL------------------->"
      elsif cached_purchase_order_updated_at == max_purchase_order_updated_at
        @data.entries[month.to_s][:purchase_order] = {
            :count => Rails.cache.read("#{month.to_s}-purchase-order-count"),
            :total => Rails.cache.read("#{month.to_s}-purchase-order-total")
        }
        puts "<----------------Cached------------------->"
      else
        @data.entries[month.to_s][:purchase_order] = {
            :count => purchase_orders_groups[month].present? ? purchase_orders_groups[month] : 0,
            :total => po.sum(&:calculated_total)
        }
        # Create cache
        create_purchase_order_cache(month.to_s, @data.entries[month.to_s][:purchase_order], max_purchase_order_updated_at)
        puts "<----------------Updated Cached------------------->"
      end
    end

    ActiveRecord::Base.default_timezone = :local

    @data
  end

  def create_inquiry_cache(month, data, max_updated_at)
    Rails.cache.write("#{month}-inquiries-updated_at", max_updated_at)
    Rails.cache.write("#{month}-inquiries-count", data[:count])
    Rails.cache.write("#{month}-inquiries-total", data[:total])
  end

  def create_quote_cache(month, data, max_updated_at)
    Rails.cache.write("#{month}-quotes-updated_at", max_updated_at)
    Rails.cache.write("#{month}-quotes-count", data[:count])
    Rails.cache.write("#{month}-quotes-total", data[:total])
  end

  def create_order_cache(month, data, max_updated_at)
    Rails.cache.write("#{month}-orders-updated_at", max_updated_at)
    Rails.cache.write("#{month}-order-count", data[:count])
    Rails.cache.write("#{month}-order-total", data[:total])
  end

  def create_invoice_cache(month, data, max_updated_at)
    Rails.cache.write("#{month}-invoices-updated_at", max_updated_at)
    Rails.cache.write("#{month}-invoices-count", data[:count])
    Rails.cache.write("#{month}-invoices-total", data[:total])
  end

  def create_purchase_order_cache(month, data, max_updated_at)
    Rails.cache.write("#{month}-purchase-order-updated_at", max_updated_at)
    Rails.cache.write("#{month}-purchase-order-count", data[:count])
    Rails.cache.write("#{month}-purchase-order-total", data[:total])
  end

end