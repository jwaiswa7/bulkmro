class Overseers::ProductsController < Overseers::BaseController
  before_action :set_product, only: [:show, :edit, :update, :sku_purchase_history, :best_prices_and_supplier_bp_catalog, :customer_bp_catalog]

  def index
    service = Services::Overseers::Finders::Products.new(params)
    service.call

    @indexed_products = service.indexed_records
    @products = service.records
    authorize @products
  end

  def autocomplete
    service = Services::Overseers::Finders::Products.new(params)
    service.call

    @indexed_products = service.indexed_records
    @products = service.records

    authorize @products
  end

  def pending
    @products = ApplyDatatableParams.to(Product.all.not_rejected.left_joins(:inquiry_products, :approval).merge(ProductApproval.where(product_id: nil)).group(:id).order('COUNT(inquiry_products.id) DESC'), params)
    authorize @products
  end

  def show
    @inquiry_products = @product.inquiry_products
    authorize @product
  end

  def new
    @product = Product.new(:overseer => current_overseer)
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

  def edit
    authorize @product
  end

  def update
    @product.assign_attributes(product_params.merge(overseer: current_overseer))
    authorize @product
    if @product.approved? ? @product.save_and_sync : @product.save
      redirect_to overseers_products_path, notice: flash_message(@product, action_name)
    end
  end

  def best_prices_and_supplier_bp_catalog
    @supplier = Company.acts_as_supplier.find(params[:supplier_id])
    @inquiry_product_supplier = InquiryProductSupplier.find(params[:inquiry_product_supplier_id]) if params[:inquiry_product_supplier_id].present?
    authorize @product

    bp_catalog = @product.bp_catalog_for_supplier(@supplier)

    render json: {
        lowest_unit_cost_price: @product.lowest_unit_cost_price_for(@supplier, @inquiry_product_supplier),
        latest_unit_cost_price: @product.latest_unit_cost_price_for(@supplier, @inquiry_product_supplier),
    }.merge!(bp_catalog ? {
        bp_catalog_name: bp_catalog[0],
        bp_catalog_sku: bp_catalog[1]
    } : {})
  end

  def customer_bp_catalog
    @company = Company.find(params[:company_id])
    authorize @product

    bp_catalog =  @product.bp_catalog_for_customer(@company)

    render json: bp_catalog ? {
        bp_catalog_name: bp_catalog[0],
        bp_catalog_sku: bp_catalog[1]
    } : {}
  end

  def sku_purchase_history
    redirect_to overseers_product_path(@product)
    authorize @product
  end

  private

  def product_params
    params.require(:product).permit(
        :name,
        :sku,
        :mpn,
        :is_service,
        :brand_id,
        :category_id,
        :tax_code_id,
        :measurement_unit_id
    )
  end

  def set_product
    @product = Product.find(params[:id])
  end
end
