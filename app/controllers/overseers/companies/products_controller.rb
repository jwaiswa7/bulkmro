class Overseers::Companies::ProductsController < Overseers::Companies::BaseController

  def index
    base_filter = {
        :base_filter_key => "id",
        :base_filter_value => Product.joins(:inquiry_products, :inquiry_product_suppliers).where(inquiry_product_suppliers: {supplier_id: params[:company_id]}).pluck(:id)
    }

    service = Services::Overseers::Finders::Products.new(params.merge(base_filter))
    service.call
    @products = service.records
    @indexed_products = service.indexed_records
    authorize @products
  end
end

