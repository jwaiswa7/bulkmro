class Customers::ProductsController < Customers::BaseController

  def index
    @cart_item = current_cart.cart_items.new
    params[:page] = 1 if (!params[:page].present? && params[:view] != "list_view")
    params[:per] = 24 if params[:view] != "list_view"
    service = Services::Customers::Finders::Products.new(params, current_contact)
    service.call
    @indexed_products = service.indexed_records
    @products = service.records.try(:reverse)
    @products_paginate = @indexed_products.page(params[:page]) if params[:page].present?

  end

  def show
  	@product = Product.find(params[:id])
  end

end
