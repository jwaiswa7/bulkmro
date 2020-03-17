class Services::Shared::Migrations::AclMigrations < Services::Shared::BaseService
  def fetch_csv(filename, csv_data)
    overseer = Overseer.find(197)
    temp_file = File.open(Rails.root.join('tmp', filename), 'wb')

    begin
      temp_file.write(csv_data)
      temp_file.close
      overseer.file.attach(io: File.open(temp_file.path), filename: filename)
      overseer.save!
      puts Rails.application.routes.url_helpers.rails_blob_path(overseer.file, only_path: true)
    rescue => ex
      puts ex.message
    end
  end

  def sales_quote_blank
    column_headers = ['inquiry', 'status', 'quotation_date']
    message = 'The Quote date was updated from Backend on 11-Mar-2020 per request from Nillesh Desai and Nutan Bala. Note - there is no actual quote in the system as these were sent from email and out of system.'
    service = Services::Shared::Spreadsheets::CsvImporter.new('Quotation_date.csv', 'seed_files_3')
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        Inquiry.where(inquiry_number: x.get_column('inquiry_number'), quotation_date: nil).each do |inquiry|
            inquiry.quotation_date = x.get_column('Quote_date')
            inquiry_comment = inquiry.comments.build(message: message, inquiry: inquiry, overseer: Overseer.find(238))
            inquiry.save(validate: false)
            inquiry_comment.save
            writer << [
                inquiry.inquiry_number,
                inquiry.status,
                inquiry.quotation_date.to_date.to_s
            ]
          end
      end
    end
    fetch_csv('quotation.csv', csv_data)
  end
end
