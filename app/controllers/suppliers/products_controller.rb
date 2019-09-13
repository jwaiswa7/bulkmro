class Suppliers::ProductsController < Suppliers::BaseController
  before_action :set_supplier_product, only: [:show]

  def index
    authorize :product

    if params[:view] == 'list_view'
      params[:per] = 20
    else
      params[:page] = 1 unless params[:page].present?
      params[:per] = 24
    end

    # ApplyDatatableParams.to(InquiryProductSupplier.where(supplier_id: current_company.id).pluck(:inquiry_product_id).uniq, params)
    @supplier_products = ApplyDatatableParams.to(Product.joins(:inquiry_product_suppliers).where(inquiry_product_suppliers: {supplier_id: current_company.id}), params)
  end

  def show
    authorize @product
  end

  private

  def set_supplier_product
    @supplier_product ||= Product.find(params[:id])
  end
end
