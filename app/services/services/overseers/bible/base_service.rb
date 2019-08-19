class Services::Overseers::Bible::BaseService < Services::Shared::BaseService

  def call
    @bible_upload_queue = BibleUpload.where(status: 'Pending')
    @bible_upload_queue.each do |upload_sheet|

      if upload_sheet.sheet_type == 'Sales Orders'
        service = Services::Overseers::Bible::CreateOrder.new(upload_sheet)
        service.call
      elsif upload_sheet.sheet_type == 'Sales Invoices'
        service = Services::Overseers::Bible::CreateInvoice.new(upload_sheet)
        service.call
      end
    end
  end

  def fetch_file_to_be_processed(upload_sheet)
    temp_path = Tempfile.open { |tempfile| tempfile << upload_sheet.bible_attachment.download }.path
    destination_path = Rails.root.join('db', 'bible_imports')
    Dir.mkdir(destination_path) unless Dir.exist?(destination_path)
    path_to_tempfile = [destination_path, '/', 'bible_file_sheet.csv'].join
    FileUtils.mv temp_path, path_to_tempfile
  end
end