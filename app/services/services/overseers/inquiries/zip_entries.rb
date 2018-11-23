class Services::Overseers::Inquiries::ZipEntries < Services::Shared::BaseService
  def initialize(record)
    @record = record
  end

  def call
    file_paths = [
                  { name: "#{record.filename}", path: RenderPdfToFile.for(record) },
                  { name: "duplicate" + "#{record.filename}", path: RenderPdfToFile.for(record,{duplicate: true}) },
                  { name: "triplicate" + "#{record.filename}", path: RenderPdfToFile.for(record,{triplicate: true}) }
                 ]

    invoice_zip = Rails.root.join('tmp/archive.zip')
    Zip::OutputStream.open(invoice_zip) { |zos| }

    Zip::File.open(invoice_zip, Zip::File::CREATE) do |zip_file|
      file_paths.each do |file_path|
        temp_invoice_file = Tempfile.new()
        temp_invoice_file.puts(File.open(file_path[:path]))
        temp_invoice_file.close

        zip_file.add(File.basename(file_path[:path]), File.join(Rails.root.join('tmp'), File.basename(file_path[:path])))
      end
    end

    File.read(invoice_zip)
  end

  attr_accessor :record
end