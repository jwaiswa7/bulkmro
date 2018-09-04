class Overseers::Inquiries::ImportsController < Overseers::Inquiries::BaseController
  before_action :set_import, only: [:show]
  before_action :set_excel_import, only: [:manage_failed_skus, :create_failed_skus]

  def index
    @imports = @inquiry.imports
    authorize @inquiry, :imports?
  end

  def show
    authorize @import

    respond_to do |format|
      format.text { render plain: @import.import_text }
    end
  end

  def new_list_import
    @list_import = @inquiry.imports.build(import_type: :list, overseer: current_overseer)
    authorize @inquiry
  end

  def create_list_import
    @list_import = @inquiry.imports.build(create_list_import_params.merge(import_type: :list, overseer: current_overseer))
    authorize @inquiry

    service = Services::Overseers::InquiryImports::ListImporter.new(@inquiry, @list_import)

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

    service = Services::Overseers::InquiryImports::ExcelImporter.new(@inquiry, @excel_import)

    if service.call
       if service.any_failed?
         redirect_to manage_failed_skus_overseers_inquiry_import_path(@inquiry, @excel_import), notice: flash_message(@inquiry, action_name)
       else
         redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
       end
    else
      render 'new_excel_import'
    end
  end

  def manage_failed_skus
    authorize @excel_import
    service = Services::Overseers::InquiryImports::BuildInquiryProducts.new(@inquiry, @excel_import)
    service.call
  end

  def create_failed_skus
    @excel_import.assign_attributes(create_failed_skus_params)

    authorize @excel_import
    service = Services::Overseers::InquiryImports::CreateFailedSkus.new(@inquiry, @excel_import)

    if service.call
      redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      service = Services::Overseers::InquiryImports::BuildInquiryProducts.new(@inquiry, @excel_import)
      service.call
      render 'manage_failed_skus'
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

  def create_excel_import_params
    params.require(:inquiry_import).permit(
        :file
    )
  end

  def create_failed_skus_params
    params.require(:inquiry_import).permit(
      :rows_attributes => [
          :id,
          :approved_alternative_id,
          :_destroy,
          :inquiry_product_attributes => [
              :inquiry_id,
              :quantity,
              :product_attributes => [:inquiry_import_row_id, :name, :sku, :brand_id, :category_id]
          ],
      ]
    )
  end
end