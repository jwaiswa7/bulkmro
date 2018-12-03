class Overseers::Companies::ProductsController < Overseers::Companies::BaseController

  def index
    @base_filter = {}
    @company = Company.find(params[:company_id])
    @product_id = Product.joins(:inquiry_products,:inquiry_product_suppliers).where(inquiry_product_suppliers: { supplier_id: @company.id }).pluck(:id)
    @base_filter[:base_filter_key] = "id"
    @base_filter[:base_filter_value] =  @product_id

    service = Services::Overseers::Finders::Products.new(params.merge(@base_filter))
    service.call
    @products = service.records
    @indexed_products = service.indexed_records
    authorize @products
  end
end

