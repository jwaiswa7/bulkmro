class Overseers::Bible::ImportsController < Overseers::BaseController
  before_action :set_bible_upload, only: [:bible_file_upload_log]

  def new_bible_import
    service = Services::Overseers::Bible::CreateOrder.new
    data = service.get_bible_file_upload_log
    @bible_file_uploads = data
    # binding.pry
    authorize_acl :bible_sales_order
  end

  def download_bible_order_template
    authorize_acl :bible_sales_order
    service = Services::Overseers::Bible::CreateOrder.new
    service.export_csv_format_for_bible
    send_file("#{Rails.root}/tmp/bible_sales_order.csv")
  end

  def create_bible_records
    authorize_acl :bible_sales_order
    bible_file = params[:file]
    bible_sheet_type = params['bible-sheet-type']
    if bible_sheet_type == 'salesorder'
      @bible_file_upload = BibleUpload.create(file_name: bible_file.original_filename.to_s, status: 'Pending', updated_by_id: current_overseer.id, sheet_type: 'Sales Orders')
      @bible_file_upload.bible_attachment.attach(params[:file])
    elsif bible_sheet_type == 'invoices'
      @bible_file_upload = BibleUpload.create(file_name: bible_file.original_filename.to_s, status: 'Pending', updated_by_id: current_overseer.id, sheet_type: 'Sales Invoices')
      @bible_file_upload.bible_attachment.attach(params[:file])
    end
    redirect_to new_bible_import_overseers_bible_imports_path
  end

  def bible_file_upload_log
    authorize_acl :bible_sales_order
  end

  private

    def bible_upload_log_params
      params.require(:bible_upload_log).permit(
        :id,
          :bible_file_upload_id,
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
