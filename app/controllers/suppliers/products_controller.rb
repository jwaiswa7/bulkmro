class Suppliers::ProductsController < Suppliers::BaseController
  before_action :set_supplier_product, only: [:show]

  # def index
  #   authorize :product
  #   binding.pry
  #   @supplier_products = ApplyDatatableParams.to(Product.joins(:inquiry_product_suppliers).where(inquiry_product_suppliers: {supplier_id: current_company.id}).distinct.with_eager_loaded_images, params)
  # end
  #
  def show
    authorize :product
  end

  def index
    authorize :product

    if params[:view] == 'list_view'
      params[:per] = 20
    else
      params[:page] = 1 unless params[:page].present?
      params[:per] = 24
    end
    service = Services::Suppliers::Finders::SupplierProducts.new(params, current_suppliers_contact, current_company)
    service.call
    @indexed_supplier_products = service.indexed_records
    @supplier_products = service.records.with_eager_loaded_images.try(:reverse)

    @supplier_products_paginate = @indexed_supplier_products.page(params[:page]) if params[:page].present?
  end

  def autocomplete
    service = Services::Overseers::Finders::SupplierProducts.new(params.merge(page: 1))
    service.call

    @indexed_supplier_products = service.indexed_records
    @supplier_products = service.records
    authorize @supplier_products
  end

  def update_price
    authorize :product
    if product_params[:product_id].present? && product_params['supplier_price'].present?
      SupplierProduct.update(product_params[:product_id], {supplier_price: product_params['supplier_price']})
    end

    if product_params['product_show'].present?
      redirect_to suppliers_product_path(product_params[:product_id])
    else
      redirect_to suppliers_products_path
    end
  end

  private

    def set_supplier_product
      @supplier_product ||= SupplierProduct.find(params[:id])
    end

    def product_params
      params.require(:supplier_product).permit(
        :product_id,
        :product_show,
        :supplier_price
      )
    end
end
