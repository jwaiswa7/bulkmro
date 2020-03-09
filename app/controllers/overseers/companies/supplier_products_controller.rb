class Overseers::Companies::SupplierProductsController < Overseers::Companies::BaseController
  before_action :set_supplier_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = ApplyDatatableParams.to(@company.supplier_products, params.reject! {|k, v| k == 'company_id'})
    authorize_acl @products
  end

  def autocomplete
    account = Account.find(params[:account_id]) if params[:account_id].present?
    company = Company.find(params[:company_id]) if params[:company_id].present?
    supplier_products = (account || company).supplier_products

    @products = ApplyParams.to(supplier_products, params)
    authorize_acl @products
  end

  def show
    authorize_acl @supplier_product
  end

  def destroy_all
    authorize_acl :customer_product
    @company.supplier_products.destroy_all

    redirect_to overseers_company_path(@company)
  end

  # def export_customer_product
  #   authorize_acl :customer_product
  #   service = Services::Overseers::Exporters::CustomerProductsExporter.new(params, current_overseer, [])
  #   service.call

  #   redirect_to url_for(Export.customer_product.last.report)
  # end

  def edit
    authorize_acl @supplier_product
    @tags = Tag.all
  end

  def update
    custom_params = supplier_product_params
    @product = Product.find(supplier_product_params[:product_id])
    @supplier_product = @company.supplier_products.where(product: @product).first_or_initialize

    custom_params[:tag_ids].reject!(&:empty?)
    custom_params[:tag_ids].each_with_index do |tag_id, index|
      @tag = @company.tags.where(id: tag_id)
      if @tag.blank?
        @new_tag = @company.tags.where(name: tag_id).first_or_create
        custom_params[:tag_ids][index] = @new_tag.id.to_s
      end
    end

    @supplier_product.assign_attributes(custom_params)
    @supplier_product.assign_attributes(name: @product.name) if @supplier_product.name.blank?
    @supplier_product.assign_attributes(sku: @product.sku) if @supplier_product.sku.blank?
    authorize_acl @supplier_product

    if @supplier_product.save
      redirect_to overseers_company_supplier_product_path(@supplier_product.company, @supplier_product), notice: flash_message(@supplier_product, action_name)
    else
      render 'edit'
    end
  end

  def destroy
    authorize_acl @supplier_product
    @supplier_product.destroy!

    redirect_to overseers_company_path(@company)
  end

  private

    def set_supplier_product
      @customer_product ||= CustomerProduct.find(params[:id])
    end

    def supplier_product_params
      params.require(:supplier_product).permit(
        :name,
          :supplier_id,
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
