class Overseers::Inquiries::ImportsController < Overseers::Inquiries::BaseController
  before_action :set_import, only: [:show]
  before_action :set_excel_import, only: [:manage_failed_skus, :create_failed_skus]
  before_action :set_notification, only: [:create_failed_skus]

  def index
    @imports = @inquiry.imports
    authorize_acl @inquiry, 'imports'
  end

  def show
    authorize_acl @import
    if params['show_failed_sku'] 
      text = "Failed SKUs"
      @import.rows.failed.map{|row| text = text +"\n"+row.sku}
    else
      text = @import.import_text
    end
    respond_to do |format|
      format.text { render plain: text }
    end
  end

  def new_list_import
    @list_import = @inquiry.imports.build(import_type: :list, overseer: current_overseer)
    authorize_acl @inquiry
  end

  def create_list_import
    @list_import = @inquiry.imports.build(create_list_import_params.merge(import_type: :list, overseer: current_overseer))
    authorize_acl @inquiry

    service = Services::Overseers::InquiryImports::ListImporter.new(@inquiry, @list_import)

    if service.call
      redirect_to overseers_inquiry_imports_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'new_list_import'
    end
  end

  def new_excel_import
    @excel_import = @inquiry.imports.build(import_type: :excel, overseer: current_overseer)
    authorize_acl @inquiry
  end

  def excel_template
    authorize_acl @inquiry
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="' + ["#{@inquiry.to_s} Excel Template", 'xlsx'].join('.') + '"'
      }
    end
  end

  def create_excel_import
    @excel_import = @inquiry.imports.build(create_excel_import_params.merge(import_type: :excel, overseer: current_overseer))
    authorize_acl @inquiry

    service = Services::Overseers::InquiryImports::ExcelImporter.new(@inquiry, @excel_import)

    begin
      if service.call
        if service.any_failed?
          redirect_to manage_failed_skus_overseers_inquiry_import_path(@inquiry, @excel_import), notice: flash_message(@inquiry, action_name)
        else
          redirect_to overseers_inquiry_imports_path(@inquiry), notice: flash_message(@inquiry, action_name)
        end
      end
    rescue Services::Overseers::InquiryImports::ExcelImporter::ExcelInvalidHeader => e
      render 'new_excel_import'
    rescue Services::Overseers::InquiryImports::ExcelImporter::ExcelInvalidRows => e
      render 'new_excel_import'
    end
  end

  def manage_failed_skus
    authorize_acl @excel_import

    service = Services::Overseers::InquiryImports::BuildInquiryProducts.new(@inquiry, @excel_import)
    service.call
  end

  def create_failed_skus
    @excel_import.assign_attributes(create_failed_skus_params)

    authorize_acl @excel_import
    service = Services::Overseers::InquiryImports::CreateFailedSkus.new(@inquiry, @excel_import)

    if service.call
      @notification.send_product_import_confirmation(
        Overseer.cataloging,
          action_name.to_sym,
          @excel_import,
          edit_overseers_inquiry_path(@inquiry),
          @excel_import.rows.map(&:sku).join(', '),
          @inquiry.inquiry_number.to_s
      )

      redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      service = Services::Overseers::InquiryImports::BuildInquiryProducts.new(@inquiry, @excel_import)
      service.call
      render 'manage_failed_skus'
    end
  end

  def new_rfq_import 
    @rfq_import = @inquiry.imports.build(import_type: :rfq, overseer: current_overseer)
    authorize_acl @inquiry
  end

  def rfq_template
    authorize_acl @inquiry
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="' + ["#{@inquiry.to_s} RFQ Template", 'xlsx'].join('.') + '"'
      }
    end
  end

  def create_rfq_import

    @rfq_import = @inquiry.imports.build(create_excel_import_params.merge(import_type: :rfq, overseer: current_overseer))
    authorize_acl @inquiry

    service = Services::Overseers::InquiryImports::RfqImporter.new(@inquiry, @rfq_import)

    begin
      if service.call
        redirect_to overseers_inquiry_imports_path(@inquiry), notice: flash_message(@inquiry, action_name)
      end
    rescue Services::Overseers::InquiryImports::RfqImporter::ExcelInvalidHeader => e
      render 'new_rfq_import'
    rescue Services::Overseers::InquiryImports::RfqImporter::ExcelInvalidRows => e
      render 'new_rfq_import'
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
      params[:inquiry_import].present? ? params.require(:inquiry_import).permit(
        rows_attributes: [
            :id,
            :approved_alternative_id,
            :_destroy,
            inquiry_product_attributes: [
                :inquiry_id,
                :quantity,
                :sr_no,
                product_attributes: [:inquiry_import_row_id, :name, :sku, :mpn, :is_service, :brand_id, :tax_code_id, :tax_rate_id, :category_id]
            ],
        ]
      ) : {}
    end
end
