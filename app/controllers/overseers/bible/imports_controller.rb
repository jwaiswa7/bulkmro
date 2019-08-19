class Overseers::Bible::ImportsController < Overseers::BaseController
  before_action :set_bible_upload, only: [:bible_upload_log]

  def new_bible_import
    service = Services::Overseers::Bible::CreateOrder.new
    data = service.get_bible_file_upload_log
    @bible_file_uploads = data
    authorize_acl :bible_upload
  end

  def download_bible_order_template
    authorize_acl :bible_upload
    bible_sheet_type = params['bible-sheet-type']
    if bible_sheet_type == 'salesorder'
      service = Services::Overseers::Bible::CreateOrder.new
      service.export_csv_format_for_bible
      send_file("#{Rails.root}/tmp/bible_sales_order.xlsx")
    elsif bible_sheet_type == 'invoices'
      service = Services::Overseers::Bible::CreateInvoice.new
      service.export_csv_format_for_bible
      send_file("#{Rails.root}/tmp/bible_sales_invoices.xlsx")
    end
    # redirect_to new_bible_import_overseers_bible_imports_path
  end

  def create_bible_records
    authorize_acl :bible_upload
    bible_file = params[:bible_upload][:file]
    bible_import_type = params[:bible_upload][:import_type]
    # binding.pry
    if bible_import_type == 'Sales Order'
      @bible_file_upload = BibleUpload.create(file: bible_file, status: 'Pending', updated_by_id: current_overseer.id, import_type: 'Sales Order')
      @bible_file_upload.bible_attachment.attach(params[:bible_upload][:file])
    elsif bible_import_type == 'Sales Invoice'
      @bible_file_upload = BibleUpload.create(file: bible_file, status: 'Pending', updated_by_id: current_overseer.id, import_type: 'Sales Invoice')
      @bible_file_upload.bible_attachment.attach(params[:bible_upload][:file])
    end
    redirect_to new_bible_import_overseers_bible_imports_path
  end

  def bible_upload_log
    authorize_acl :bible_upload
  end

  private

    def bible_upload_log_params
      params.require(:bible_upload_log).permit(
        :id,
          :bible_upload_id,
          :sr_no,
          :status,
          :bible_row_data,
          :error
      )
    end

    def set_bible_upload
      @bible_file_uploads = BibleUploadLog.where(bible_upload_id: BibleUpload.decode_id(params[:id]))
    end
end
