PaperTrail.request(enabled: false) do

  service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_attachments.csv')
  service.loop(nil) do |x|
    inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))
    next if inquiry.blank?
    sheet_columns = [
        ['calculation_sheet', 'calculation_sheet_path', 'calculation_sheet'],
        ['customer_po_sheet', 'customer_po_sheet_path', 'customer_po_sheet'],
        ['email_attachment', 'email_attachment_path', 'copy_of_email'],
        ['supplier_quote_attachment', 'sqa_path', 'supplier_quotes'],
        ['supplier_quote_attachment_additional', 'sqa_additional_path', 'final_supplier_quote']
    ]

    sheet_columns.each do |file|
      file_url = x.get_column(file[1])
      next if file_url.in? %w(https://bulkmro.com/media/quotation_attachment/tender_order_calc_308.xlsx)
      next if inquiry.send(file[2]).attached?
      attach_file(inquiry, filename: x.get_column(file[0]), field_name: file[2], file_url: file_url)
    end
  end
end

def attach_file(inquiry, filename:, field_name:, file_url:)
  if file_url.present? && filename.present?
    url = URI.parse(file_url)
    req = Net::HTTP.new(url.host, url.port)
    req.use_ssl = true
    res = req.request_head(url.path)
    puts "---------------------------------"
    if res.code == '200'
      file = open(file_url)
      inquiry.send(field_name).attach(io: file, filename: filename)
    else
      puts res.code
    end
  end
end