class Services::Overseers::SalesInvoices::Zipped < Services::Shared::BaseService
  def initialize(record)
    @record = record
  end

  def call
    files = [
        {name: "original_#{record.filename}.pdf", path: RenderPdfToFile.for(record)},
        {name: "duplicate_#{record.filename}.pdf", path: RenderPdfToFile.for(record, {duplicate: true})},
        {name: "triplicate_#{record.filename}.pdf", path: RenderPdfToFile.for(record, {triplicate: true})}
    ]

    invoice_zip = Rails.root.join('tmp', 'archive.zip')

    Zip::OutputStream.open(invoice_zip) {|os|}

    Zip::File.open(invoice_zip, Zip::File::CREATE) do |zip_file|
      files.each do |file|
        temp_invoice_file = Tempfile.new
        temp_invoice_file.puts(File.open(file[:path]))
        temp_invoice_file.close

        zip_file.add((file[:name]), File.join(Rails.root.join('tmp'), File.basename(file[:path])))
      end
    end

    File.read(invoice_zip)
  end

  attr_accessor :record
end