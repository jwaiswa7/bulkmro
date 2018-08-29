class Overseers::Inquiries::ImportsController < Overseers::Inquiries::BaseController
  before_action :set_import, only: [:show, :create_pending_products]
  before_action :set_excel_import, only: [:manage_failed_skus,:create_pending_products]

  def new_list_import
    @list_import = @inquiry.imports.build(import_type: :list, overseer: current_overseer)
    authorize @inquiry
  end

  def create_list_import
    @list_import = @inquiry.imports.build(create_list_import_params.merge(import_type: :list, overseer: current_overseer))
    authorize @inquiry

    service = Services::Overseers::Inquiries::ListImporter.new(@inquiry, @list_import)

    if service.call
      redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'new_list_import'
    end
  end

  def new_excel_import
    @excel_import = @inquiry.imports.build(import_type: :excel, overseer: current_overseer)
    authorize @inquiry
  end

  def excel_template
    authorize @inquiry
  end

  def create_excel_import
    @excel_import = @inquiry.imports.build(create_excel_import_params.merge(import_type: :excel, overseer: current_overseer))
    authorize @inquiry

    service = Services::Overseers::Inquiries::ExcelImporter.new(@inquiry, @excel_import)
    service.call

    if @excel_import.persisted?
      if @excel_import.failed_skus.length > 0
        redirect_to manage_failed_skus_overseers_inquiry_import_path(@inquiry, @excel_import)
      else
        redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
      end

    else
      render 'new_excel_import'
    end
  end

  def manage_failed_skus
    authorize @inquiry

    @failed_products = []
    @excel_import.failed_skus_metadata.each do |product|
      failed_product = Product.new
      failed_product.name = product["name"]
      failed_product.sku = product["sku"]
      brand = Brand.find_by_name(product["brand"])
      if brand.present?
        failed_product.brand_id = brand.id
      end

      @failed_products << failed_product
    end
    @failed_products
  end

  def create_pending_products
    authorize @inquiry
    service = Services::Overseers::Inquiries::MassUploader.new(@inquiry, @excel_import, create_failed_product_import_params, current_overseer)
    service.call

    if @excel_import.failed_skus.length > 0
      redirect_to manage_failed_skus_overseers_inquiry_import_path(@inquiry, @excel_import)
    else
      redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
    end

  end

  def index
    @imports = @inquiry.imports
    authorize @inquiry, :imports_index?
  end

  def show
    authorize @inquiry, :show_import?

    respond_to do |format|
      format.text {render plain: @import.import_text}
    end
  end

  private

  def set_import
    @import = @inquiry.imports.find(params[:id])
  end

  def set_excel_import
    @excel_import = @inquiry.imports.find(params[:id])
  end

  def create_list_import_params
    params.require(:inquiry_import).permit(
        :import_text
    )
  end

  def create_failed_product_import_params
    params.require(:products)
  end

  def create_excel_import_params
    params.require(:inquiry_import).permit(
        :file
    )
  end
end