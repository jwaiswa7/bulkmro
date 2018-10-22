class Customers::ProductsController < Customers::BaseController

  def index
  	@products = current_contact.account.products.approved
    
  end

  def show
  	@product = Product.find(params[:id])
  end

end
