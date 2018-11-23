class Services::Overseers::Inquiries::ZipEntries < Services::Shared::BaseService

  def initialize(record)
    @record = record
  end

  def call
    folder = Rails.root.join('tmp')
    # input_filenames = ["invoice.pdf","duplicate.pdf","triplicate.pdf"]

    temp_invoice_file = Tempfile.new()
    temp_invoice_file.puts(File.open(RenderPdfToFile.for(record)))
    temp_invoice_file.close

    puts "Tempfilename", File.basename(RenderPdfToFile.for(record))

    temp_zip_file = 'tmp/archive.zip'

    Zip::File.open(temp_zip_file, Zip::File::CREATE) do |zip_file|
      # input_filenames.each do |filename|
      zip_file.add(File.basename(RenderPdfToFile.for(record)), File.join(folder,File.basename(RenderPdfToFile.for(record))))
      # end
    end

    zip_data = File.read(temp_zip_file)
    send_data(zip_data, :type => 'application/zip', :filename => "Invoice - "+record.invoice_number.to_s)
  end

  attr_accessor :record
end