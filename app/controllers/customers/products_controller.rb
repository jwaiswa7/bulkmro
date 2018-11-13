class Customers::ProductsController < Customers::BaseController
  before_action :set_product, only: [:show]
  def index
    authorize :product

    if params[:view] == 'list_view'
      params[:per] = 20
    elsif params[:view] == 'grid_view'
      params[:page] = 1 unless params[:page].present?
      params[:per] = 24
    end

    service = Services::Customers::Finders::Products.new(params, current_contact)
    service.call

    @indexed_products = service.indexed_records
    @products = service.records.try(:reverse)
    @products_paginate = @indexed_products.page(params[:page]) if params[:page].present?
  end

  def show
    authorize @product
  end

  private
  def set_product
    @product = Product.find(params[:id])
  end
end
