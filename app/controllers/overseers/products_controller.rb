class Overseers::ProductsController < Overseers::BaseController
  before_action :set_product, only: [:show, :edit, :update, :sku_purchase_history, :best_prices_and_supplier_bp_catalog, :customer_bp_catalog, :resync, :resync_inventory, :get_product_details]

  def index
    service = Services::Overseers::Finders::Products.new(params)
    service.call
    @indexed_products = service.indexed_records
    @products = service.records
    authorize_acl @products
  end

  def autocomplete
    service = Services::Overseers::Finders::Products.new(params.merge(page: 1))
    service.call
    @indexed_products = service.indexed_records
    @products = service.records.active
    authorize_acl @products
  end

  def suggestion
    authorize_acl :product
    service = Services::Overseers::Finders::Products.new(params)
    service.call

    product_names = service.indexed_records.suggest['product-suggest'].map {|p| p['options']}
    render json: {product_names: product_names.first}.to_json
  end

  def autocomplete_mpn
    @label = params[:label] || :to_s
    service = Services::Overseers::Finders::Products.new(params, sort_by: 'mpn', sort_order: 'desc')
    service.call
    @indexed_products = service.indexed_records
    @products = service.records.active
    authorize_acl @products
  end

  def non_kit_autocomplete
    base_filter = {
        base_filter_key: 'is_not_kit',
        base_filter_value: true
    }

    service = Services::Overseers::Finders::Products.new(params.merge(page: 1).merge(base_filter))
    service.call

    @indexed_products = service.indexed_records
    @products = service.records
    authorize_acl @products
  end

  def service_autocomplete
    base_filter = {
        base_filter_key: 'is_service',
        base_filter_value: true
    }
    service = Services::Overseers::Finders::Products.new(params.merge(page: 1).merge(base_filter))
    service.call

    @indexed_products = service.indexed_records
    @products = service.records
    authorize_acl @products
  end

  def pending
    @products = ApplyDatatableParams.to(Product.all.not_rejected.left_joins(:inquiry_products, :approval).merge(ProductApproval.where(product_id: nil)), params)
    authorize_acl @products
  end

  def show
    @inquiry_products = @product.inquiry_products
    authorize_acl @product
  end

  def new
    @product = Product.new(overseer: current_overseer)
    authorize_acl @product
  end

  def create
    @product = Product.new(product_params.merge(overseer: current_overseer))
    authorize_acl @product
    if @product.approved? ? @product.save_and_sync : @product.save
      redirect_to overseers_product_path(@product), notice: flash_message(@product, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize_acl @product
  end

  def update
    @product.assign_attributes(product_params.merge(overseer: current_overseer))
    authorize_acl @product
    if @product.approved? ? @product.save_and_sync : @product.save
      redirect_to overseers_product_path(@product), notice: flash_message(@product, action_name)
    else
      render 'edit'
    end
  end

  def best_prices_and_supplier_bp_catalog
    @supplier = Company.acts_as_supplier.find(params[:supplier_id])
    @inquiry_product_supplier = InquiryProductSupplier.find(params[:inquiry_product_supplier_id]) if params[:inquiry_product_supplier_id].present?
    authorize_acl @product

    bp_catalog = @product.bp_catalog_for_supplier(@supplier)

    render json: {
        supplier_id: @supplier.id,
        lowest_unit_cost_price: @product.lowest_unit_cost_price_for(@supplier, @inquiry_product_supplier),
        latest_unit_cost_price: @product.latest_unit_cost_price_for(@supplier, @inquiry_product_supplier),
        rating: @supplier.rating
    }.merge!(bp_catalog ? {
        bp_catalog_name: bp_catalog[0],
        bp_catalog_sku: bp_catalog[1]
    } : {})
  end

  def customer_bp_catalog
    @company = Company.find(params[:company_id])
    authorize_acl @product

    bp_catalog = @product.bp_catalog_for_customer(@company)

    render json: bp_catalog ? {
        bp_catalog_name: bp_catalog[0],
        bp_catalog_sku: bp_catalog[1]
    } : {}
  end

  def sku_purchase_history
    authorize_acl @product
    redirect_to overseers_product_path(@product)
  end

  def resync
    authorize_acl @product
    if @product.save_and_sync
      redirect_to overseers_product_path(@product), notice: flash_message(@product, action_name)
    end
  end

  def resync_inventory
    authorize_acl @product
    service = Services::Resources::Products::UpdateInventory.new([@product])
    service.resync
    redirect_to overseers_product_path(@product, anchor: 'inventory'), notice: flash_message(@product, action_name)
  end

  def export_all
    authorize_acl :product
    service = Services::Overseers::Exporters::ProductsExporter.new(params[:q], current_overseer, [])
    service.call

    redirect_to url_for(Export.products.not_filtered.completed.last.report)
  end

  def export_filtered_records
    authorize_acl :product
    service = Services::Overseers::Finders::Products.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::ProductsExporter.new([], current_overseer, service.records.pluck(:id))
    export_service.call
  end


  def autocomplete_suppliers
    authorize_acl @product
    suppliers = {}
    @product.suppliers.each do |supplier|
      [supplier.name, supplier.id]
    end
    render json: suppliers
  end

  def get_product_details
    authorize_acl @product
    product_details = {}
    product_details['brand'] = @product.brand.to_s
    product_details['tax_code_id'] = @product.best_tax_code.id
    product_details['tax_rate_id'] = @product.best_tax_rate.id
    product_details['measurement_unit'] = @product.measurement_unit.to_s
    product_details['converted_unit_selling_price'] = @product.latest_unit_cost_price
    product_details['mpn'] = @product.mpn
    product_details['category'] = @product.category.to_s
    render json: product_details
  end

  private

    def product_params
      params.require(:product).permit(
        :name,
          :sku,
          :mpn,
          :is_service,
          :is_active,
          :brand_id,
          :category_id,
          :tax_code_id,
          :tax_rate_id,
          :measurement_unit_id,
          images: []
      )
    end

    def set_product
      @product = Product.find(params[:id])
    end
end
