class Customers::DashboardController < Customers::BaseController

  def show
    @contact = current_contact
    @contact_account = @contact.account
    @products_count = @contact_account.products.count
    @sales_quotes_count = @contact_account.sales_quotes.count
    @sales_orders_count = @contact_account.sales_orders.count

    @recent_sales_quotes = SalesQuote.last(5)
    @recent_sales_orders = SalesOrder.where(:status => :'Approved').last(5)
    @most_ordered_products =  InquiryProduct.top(:product_id, 5).map { |id, c| [Product.find(id), c]}
  end

end