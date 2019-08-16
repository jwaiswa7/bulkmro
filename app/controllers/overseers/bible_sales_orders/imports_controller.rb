class Overseers::BibleSalesOrders::ImportsController < Overseers::BaseController
  before_action :set_bible_upload, only: [:bible_file_upload_log]

  def new_excel_bible_order_import
    service = Services::Overseers::Bible::CreateOrder.new
    data = service.get_bible_file_upload_log
    @bible_file_uploads = data
    authorize_acl :bible_sales_order
  end

  def download_bible_order_template
    authorize_acl :bible_sales_order
    service = Services::Overseers::Bible::CreateOrder.new
    service.export_csv_format_for_bible
    send_file("#{Rails.root}/tmp/bible_sales_order.csv")
  end

  def create_bible_orders
    authorize_acl :bible_sales_order
    bible_file = params[:file]
    @bible_file_upload = BibleFileUpload.create(file_name: bible_file.original_filename.to_s, status: 'Pending', updated_by_id: current_overseer.id)
    @bible_file_upload.bible_attachment.attach(params[:file])
    redirect_to new_excel_bible_order_import_overseers_bible_sales_orders_imports_path
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
      @bible_file_uploads = BibleUploadLog.where(bible_file_upload_id: BibleFileUpload.decode_id(params[:id]))
    end
end
