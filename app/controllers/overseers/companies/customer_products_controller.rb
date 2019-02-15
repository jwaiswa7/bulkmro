class Overseers::Companies::CustomerProductsController < Overseers::Companies::BaseController
  before_action :set_customer_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = ApplyDatatableParams.to(@company.customer_products, params.reject! { |k, v| k == 'company_id' })
    authorize @products
  end

  def autocomplete
    account = Account.find(params[:account_id]) if params[:account_id].present?
    company = Company.find(params[:company_id]) if params[:company_id].present?
    customer_products = (account || company).customer_products

    @products = ApplyParams.to(customer_products, params)
    authorize @products
  end

  def show
    authorize @customer_product
  end

  def new
    @tags = Tag.all
    @customer_product = @company.customer_products.new(overseer: current_overseer)
    authorize @customer_product
  end

  def create
    custom_params = customer_product_params
    @product = Product.find(customer_product_params[:product_id])
    @customer_product = @company.customer_products.where(product: @product).first_or_initialize

    custom_params[:tag_ids].reject!(&:empty?)
    custom_params[:tag_ids].each_with_index do |tag_id, index|
      @tag = @company.tags.where(id: tag_id)
      if @tag.blank?
        @new_tag = @company.tags.where(name: tag_id).first_or_create
        custom_params[:tag_ids][index] = @new_tag.id.to_s
      end
    end

    @customer_product.assign_attributes(custom_params)
    @customer_product.assign_attributes(name: @product.name) if @customer_product.name.blank?
    @customer_product.assign_attributes(sku: @product.sku) if @customer_product.sku.blank?

    authorize @customer_product

    if @customer_product.save
      redirect_to overseers_company_customer_product_path(@company, @customer_product), notice: flash_message(@customer_product, action_name)
    else
      render 'edit'
    end
  end

  def generate_catalog
    authorize :customer_product
    @company.generate_catalog(current_overseer)

    redirect_to overseers_company_path(@company)
  end

  def destroy_all
    authorize :customer_product
    @company.customer_products.destroy_all

    redirect_to overseers_company_path(@company)
  end


  def edit
    authorize @customer_product
    @tags = Tag.all
  end

  def update
    custom_params = customer_product_params
    @product = Product.find(customer_product_params[:product_id])
    @customer_product = @company.customer_products.where(product: @product).first_or_initialize

    custom_params[:tag_ids].reject!(&:empty?)
    custom_params[:tag_ids].each_with_index do |tag_id, index|
      @tag = @company.tags.where(id: tag_id)
      if @tag.blank?
        @new_tag = @company.tags.where(name: tag_id).first_or_create
        custom_params[:tag_ids][index] = @new_tag.id.to_s
      end
    end

    @customer_product.assign_attributes(custom_params)
    @customer_product.assign_attributes(name: @product.name) if @customer_product.name.blank?
    @customer_product.assign_attributes(sku: @product.sku) if @customer_product.sku.blank?
    authorize @customer_product

    if @customer_product.save
      redirect_to overseers_company_customer_product_path(@customer_product.company, @customer_product), notice: flash_message(@customer_product, action_name)
    else
      render 'edit'
    end
  end

  def destroy
    authorize @customer_product
    @customer_product.destroy!

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
          tag_ids: [],
          images: []
      )
    end
end
