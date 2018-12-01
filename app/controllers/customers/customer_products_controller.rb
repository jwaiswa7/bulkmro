class Customers::CustomerProductsController < Customers::BaseController
  before_action :set_customer_product, only: [:show]

  def index
    authorize :customer_product

    if params[:view] == 'list_view'
      params[:per] = 20
    else
      params[:page] = 1 unless params[:page].present?
      params[:per] = 24
    end

    service = Services::Customers::Finders::CustomerProducts.new(params, current_contact)
    service.call

    @indexed_customer_products = service.indexed_records
    @customer_products = service.records.try(:reverse)
    @customer_products_paginate = @indexed_customer_products.page(params[:page]) if params[:page].present?
  end

  def show
    authorize @customer_product
  end

  private
  def set_customer_product
    @customer_product ||= CustomerProduct.find(params[:id])
  end
end
