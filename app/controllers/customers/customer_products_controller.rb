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

  def new
    @customer_product = CustomerProduct.new(:overseer => current_overseer)
    authorize @product
  end

  def create
    @product = Product.new(product_params.merge(overseer: current_overseer))
    authorize @product
    if @product.approved? ? @product.save_and_sync : @product.save
      redirect_to overseers_products_path, notice: flash_message(@product, action_name)
    else
      render 'new'
    end
  end

  def generate_all
    authorize :customer_product
    current_contact.generate_products

    redirect_to customers_customer_products_url
  end

  private

  def set_customer_product
    @customer_product ||= CustomerProduct.find(params[:id])
  end

end
