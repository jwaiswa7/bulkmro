class Customers::DashboardController < Customers::BaseController

  def show
    @contact = current_contact
    @contact_account = @contact.account
    @products_count = @contact_account.products.count
    @sales_quotes_count = @contact_account.sales_quotes.count
    @sales_orders_count = @contact_account.sales_orders.count
  end

end