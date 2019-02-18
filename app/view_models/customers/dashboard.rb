class Customers::Dashboard
  def initialize(contact)
    @contact = contact
    @account = contact.account
  end

  def sales_orders
    SalesOrder.with_includes.joins(:inquiry, :company).where('inquiries.company_id in (?)', record.companies.pluck(:id)).where('sales_orders.created_at > ?', Date.new(2018, 04, 01)).where.not(order_number: nil).approved.not_rejected.latest
  end

  def sales_quotes
    SalesQuote.with_includes.joins(:inquiry).where('inquiries.company_id in (?)', record.companies.pluck(:id)).where('inquiries.status not in (?)', Inquiry.statuses[:'Order Lost']).where('sales_quotes.created_at > ?', Date.new(2018, 04, 01)).where.not(sent_at: nil).order('inquiries.inquiry_number DESC').distinct(:inquiry_id).uniq { |p| p.inquiry_id }
  end

  def sales_invoices
    SalesInvoice.with_includes.where(sales_order: sales_orders).where('created_at > ?', Date.new(2018, 4, 30)).latest
  end

  def recent_sales_quotes
    sales_quotes.first(5)
  end

  def recent_sales_orders
    sales_orders.first(5)
  end

  def recent_sales_invoices
    sales_invoices.first(4)
  end

  def record
    if contact.account_manager?
      account
    else
      contact
    end
  end

  attr_reader :contact, :account
end
