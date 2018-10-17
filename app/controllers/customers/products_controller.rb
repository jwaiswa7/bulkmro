class Customers::ProductsController < Customers::BaseController

  def index
    products = current_contact.account.products
    @products = ApplyDatatableParams.to(products, params)
  end

end
