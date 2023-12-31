class Overseers::Companies::CustomerProductsController < Overseers::Companies::BaseController
  before_action :set_customer_product, only: [:show, :edit, :update, :destroy]

  def index

    authorize_acl :product

    base_filter = {
        base_filter_key: 'company_id',
        base_filter_value: @company.id
    }
    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::CustomerProducts.new(params.merge(base_filter), current_overseer)
        service.call
        @indexed_addresses = service.indexed_records
        @products = service.records
      end
    end
  end


  def autocomplete
    account = Account.find(params[:account_id]) if params[:account_id].present?
    company = Company.find(params[:company_id]) if params[:company_id].present?
    customer_products = (account || company).customer_products

    @products = ApplyParams.to(customer_products, params)
    authorize_acl @products
  end

  def show
    authorize_acl @customer_product
  end

  def new
    @tags = Tag.all
    @customer_product = @company.customer_products.new(overseer: current_overseer)
    authorize_acl @customer_product
  end

  def create
    custom_params = customer_product_params
    @product = Product.find(customer_product_params[:product_id])
    @customer_product = @company.customer_products.where(product: @product).first_or_initialize

    @customer_product.assign_attributes(custom_params)
    @customer_product.assign_attributes(name: @product.name) if @customer_product.name.blank?
    @customer_product.assign_attributes(sku: @product.sku) if @customer_product.sku.blank?

    authorize_acl @customer_product

    if @customer_product.save
      redirect_to overseers_company_customer_product_path(@company, @customer_product), notice: flash_message(@customer_product, action_name)
    else
      render 'edit'
    end
  end

  def generate_catalog
    authorize_acl :customer_product
    GenerateCatalogJob.perform_later(@company.id, current_overseer.id)
    redirect_to overseers_company_path(@company), notice: 'Catalog successfully generated.'
  end

  def destroy_all
    authorize_acl :customer_product

    DestroyAllCompanyProductsJob.perform_later(@company.id)

    redirect_to overseers_company_path(@company), notice: 'Request has been succcessfully submitted'
  end

  def export_customer_product
    authorize_acl :customer_product
    service = Services::Overseers::Exporters::CustomerProductsExporter.new(params, current_overseer, [])
    service.call

    redirect_to url_for(Export.customer_products.last.report)
  end

  def edit
    authorize_acl @customer_product
    @tags = Tag.all
  end

  def update
    custom_params = customer_product_params
    @product = Product.find(customer_product_params[:product_id])
    @customer_product = @company.customer_products.where(product: @product).first_or_initialize

    @customer_product.assign_attributes(custom_params)
    @customer_product.assign_attributes(name: @product.name) if @customer_product.name.blank?
    @customer_product.assign_attributes(sku: @product.sku) if @customer_product.sku.blank?
    authorize_acl @customer_product

    if @customer_product.save
      redirect_to overseers_company_customer_product_path(@customer_product.company, @customer_product), notice: flash_message(@customer_product, action_name)
    else
      render 'edit'
    end
  end

  def destroy
    authorize_acl @customer_product
    @customer_product.destroy!

    redirect_to overseers_company_path(@company)
  end

  def toggle_view
    @company.grid_view? ? @company.update(grid_view: false) : @company.update(grid_view: true)
    redirect_to overseers_company_path(@company)
  end

  private

    def set_customer_product
      @customer_product ||= CustomerProduct.find(params[:id])
    end

    def customer_product_params
      params.require(:customer_product).permit(
        :name,
        :company_id,
        :product_id,
        :tax_code_id,
        :tax_rate_id,
        :measurement_unit_id,
        :customer_price,
        :sku,
        :brand_id,
        :moq,
        :technical_description,
        :customer_product_sku,
        :lead_time,
        :customer_uom,
        :published,
        tag_ids: [],
        images: []
      )
    end
end
