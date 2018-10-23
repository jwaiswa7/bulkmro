class Customers::ProductsController < Customers::BaseController

  def index
    account = current_contact.account
    @products = ApplyDatatableParams.to(account.products.approved, params)
    @cart_item = current_cart.cart_items.new
  end

  def show
  	@product = Product.find(params[:id])
  end

end
