class Customers::ProductsController < Customers::BaseController

  def index
    @cart_item = current_cart.cart_items.new
    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Customers::Finders::Products.new(params, current_contact)
        service.call

        @indexed_products = service.indexed_records
        @products = service.records.try(:reverse)
      end
    end
  end

  def show
  	@product = Product.find(params[:id])
  end

end
