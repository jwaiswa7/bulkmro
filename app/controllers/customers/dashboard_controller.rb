class Customers::DashboardController < Customers::BaseController

  def show
    indexed_sales_quotes = Services::Customers::Finders::SalesQuotes.new(params.merge(page: 1).merge(per: 5), current_contact, current_company)
    @recent_sales_quotes = indexed_sales_quotes.call.records.try(:reverse)
    indexed_sales_orders = Services::Customers::Finders::SalesOrders.new(params.merge(page: 1).merge(per: 5), current_contact, current_company)
    @recent_sales_orders = indexed_sales_orders.call.records
    indexed_sales_invoices = Services::Customers::Finders::SalesInvoices.new(params.merge(page: 1).merge(per: 5), current_contact, current_company)
    @recent_sales_invoices = indexed_sales_invoices.call.records.try(:reverse)
    @dashboard = Customers::Dashboard.new(current_contact, current_company, params)
    authorize :dashboard
  end

  attr_accessor :contact, :account
end