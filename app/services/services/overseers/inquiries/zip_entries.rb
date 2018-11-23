class Services::Overseers::Inquiries::ZipEntries < Services::Shared::BaseService
  def initialize(record)
    @record = record
  end

  def call
    file_paths = [
                  { name: "original_#{record.filename}.pdf", path: RenderPdfToFile.for(record) },
                  { name: "duplicate_#{record.filename}.pdf", path: RenderPdfToFile.for(record,{duplicate: true}) },
                  { name: "triplicate_#{record.filename}.pdf", path: RenderPdfToFile.for(record,{triplicate: true}) }
                 ]

    invoice_zip = Rails.root.join('tmp/archive.zip')
    Zip::OutputStream.open(invoice_zip) { |zos| }

    Zip::File.open(invoice_zip, Zip::File::CREATE) do |zip_file|
      file_paths.each do |file_path|
        temp_invoice_file = Tempfile.new()
        temp_invoice_file.puts(File.open(file_path[:path]))
        temp_invoice_file.close

        zip_file.add((file_path[:name]), File.join(Rails.root.join('tmp'), File.basename(file_path[:path])))
      end
    end

    File.read(invoice_zip)
  end

  attr_accessor :record
end