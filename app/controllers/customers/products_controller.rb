class Customers::ProductsController < Customers::BaseController

  def index
    account = current_contact.account
    @products = ApplyDatatableParams.to(account.products.approved, params)
  end

  def show
  	@product = Product.find(params[:id])
  end

end
