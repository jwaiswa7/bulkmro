class Suppliers::ProductsController < Suppliers::BaseController
  before_action :set_supplier_product, only: [:show]

  def index
    authorize :product

    # ApplyDatatableParams.to(InquiryProductSupplier.where(supplier_id: current_company.id).pluck(:inquiry_product_id).uniq, params)
    @supplier_products = ApplyDatatableParams.to(Product.joins(:inquiry_product_suppliers).where(inquiry_product_suppliers: {supplier_id: current_company.id}), params)
  end

  def show
    authorize @product
  end

  def update_price
    authorize :product
    id = params[:id]
    if id.present? && params[:product]['supplier_unit_cost_price'].present?
      product = Product.find(id)
      product.update_attributes(supplier_unit_cost_price: params[:product]['supplier_unit_cost_price'])
    end

    redirect_to suppliers_products_path(view: 'grid_view')
  end

  private

  def set_supplier_product
    @supplier_product ||= Product.find(params[:id])
  end
end
