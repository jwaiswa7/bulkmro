class Overseers::Bible::ImportsController < Overseers::BaseController
  before_action :set_bible_upload, only: [:bible_upload_log]

  def new_bible_import
    authorize_acl :bible_upload

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::BibleUploads.new(params, current_overseer)
        service.call

        @indexed_bible_uploads = service.indexed_records
        @bible_uploads = service.records
      end
    end
  end

  def download_bible_order_template
    authorize_acl :bible_upload
    bible_sheet_type = params['bible-sheet-type']
    service = Services::Overseers::Bible::BaseService.new
    service.export_csv_format_for_bible(bible_sheet_type)
    send_file("#{Rails.root}/tmp/bible_#{bible_sheet_type.underscore}.xlsx")

    # redirect_to new_bible_import_overseers_bible_imports_path
  end

  def create_bible_records
    authorize_acl :bible_upload

    bible_file = params[:bible_upload][:file]
    bible_import_type = params[:bible_upload][:import_type]
    @bible_file_upload = BibleUpload.create(file: bible_file.original_filename.to_s, status: 'Pending', updated_by_id: current_overseer.id, import_type: bible_import_type)
    @bible_file_upload.bible_attachment.attach(bible_file)

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
    @bible_uploads = BibleUploadLog.where(bible_upload_id: BibleUpload.decode_id(params[:id]))
  end
end
