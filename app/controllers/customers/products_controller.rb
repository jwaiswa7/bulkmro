class Customers::ProductsController < Customers::BaseController

  def index
    @cart_item = current_cart.cart_items.new
    @products_paginate = current_contact.account.products.approved.page(params[:page])
    respond_to do |format|
      if params[:view] == "grid_view"
        format.js { render 'index.js.erb' }
      else
        format.json do
          service = Services::Customers::Finders::Products.new(params, current_contact)
          service.call
          @indexed_products = service.indexed_records
          @products = service.records.try(:reverse)
        end
      end
      format.html {}
    end
  end

  def show
  	@product = Product.find(params[:id])
  end

end
