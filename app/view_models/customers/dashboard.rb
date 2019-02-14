

class Customers::Dashboard
  def initialize(contact, company, params)
    @contact = contact
    @account = contact.account
    @company = company
    @params = params
  end

  def recent_sales_quotes
    indexed_sales_quotes = Services::Customers::Finders::SalesQuotes.new(params.merge(page: 1).merge(per: 5), contact, company)
    indexed_sales_quotes.call.records.try(:reverse)
  end

  def recent_sales_orders
    indexed_sales_orders = Services::Customers::Finders::SalesOrders.new(params.merge(page: 1).merge(per: 5), contact, company)
    indexed_sales_orders.call.records
  end

  def recent_sales_invoices
    indexed_sales_invoices = Services::Customers::Finders::SalesInvoices.new(params.merge(page: 1).merge(per: 5), contact, company)
    indexed_sales_invoices.call.records.try(:reverse)
  end
  
  def record
    if contact.account_manager?
      account
    else
      contact
    end
  end

  attr_reader :contact, :account, :company, :params
end
