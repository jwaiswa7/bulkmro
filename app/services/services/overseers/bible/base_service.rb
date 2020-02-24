class Services::Overseers::Bible::BaseService < Services::Shared::BaseService
  def call(upload_sheet)
    # @bible_upload_queue = BibleUpload.where(status: 'Pending')
    # @bible_upload_queue.each do |upload_sheet|
      if upload_sheet.import_type == 'Sales Order'
        service = Services::Overseers::Bible::CreateOrder.new(upload_sheet)
        service.call
      elsif upload_sheet.import_type == 'Sales Invoice'
        service = Services::Overseers::Bible::CreateInvoice.new(upload_sheet)
        service.call
      end
    # end
  end

  def fetch_file_to_be_processed(upload_sheet)
    temp_path = Tempfile.open { |tempfile| tempfile << upload_sheet.file.download }.path
    destination_path = Rails.root.join('db', 'bible_imports')
    Dir.mkdir(destination_path) unless Dir.exist?(destination_path)
    @path_to_tempfile = [destination_path, '/', 'bible_file_sheet.csv'].join
    FileUtils.mv temp_path, @path_to_tempfile
  end

  def export_csv_format_for_bible(bible_sheet_type)
    file_name = "#{Rails.root}/tmp/bible_#{bible_sheet_type.underscore}.csv"
    headers = fixed_header(bible_sheet_type)
    csv_data = CSV.generate(write_headers: true, headers: headers) do |writer|
    end
    temp_file = File.open(file_name, 'wb')
    temp_file.write(csv_data)
    temp_file.close
  end

  def fixed_header(bible_sheet_type)
    if bible_sheet_type.underscore == 'sales_orders'
      headers = ['Inside Sales Name', 'Client Order #', 'Client Order Date', 'Price Currency', 'Document Rate', 'Magento Company Name', 'Company Alias', 'Inquiry Number', 'So #', 'Order Date', 'Bm #', 'Description', 'Order Qty', 'Unit Selling Price', 'Freight', 'Tax Type', 'Tax Rate', 'Tax Amount', 'Total Selling Price', 'Total Landed Cost', 'Unit cost price', 'Margin', 'Margin (In %)', 'So Month Code']
    elsif bible_sheet_type.underscore == 'sales_invoices'
      headers = ['Branch', 'Inquiry #', 'Invoice/Credit Note', 'Company Name', 'Invoice Number', 'Invoice Date', 'Month Code', 'New SKU', 'Description', 'Qty', 'Rate', 'Invoice Amount in Local Curr.', 'Invoice Currency', 'Exchange Rate', 'Invoice Amount in INR', 'Supplier Name', 'AP Ref. No.', 'Quantity', 'Purchase Cost', 'Cost Of Good Sold (Viz. Sales Qty)', 'Gross Margin Amount', 'Gross Margin %']
    end
    headers
  end

  def get_inquiry(inquiry_number)
    if inquiry_number.include?('.') || inquiry_number.include?('/') || inquiry_number.include?('-') || inquiry_number.match?(/[a-zA-Z]/)
      Inquiry.find_by_old_inquiry_number(inquiry_number)
    else
      Inquiry.find_by_inquiry_number(inquiry_number.to_i)
    end
  end

  def create_upload_log(status, upload_id, row_data, error_message, sr_no = nil)
    BibleUploadLog.create(status: status, bible_upload_id: upload_id, bible_row_data: row_data, error: error_message, sr_no: sr_no)
  end
end
