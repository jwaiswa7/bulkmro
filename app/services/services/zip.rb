# require 'rubyzip'
class Services::Zip < Services::Shared::BaseService
  include Zip
  def initialize(invoice)
    @record_pdf = invoice
  end

  def call

    tf = Tempfile.new('archive.zip')

    temp_file = Tempfile.new('invoice')
    temp_file.puts File.open(RenderPdfToFile.for(record_pdf))
    temp_file.close

    puts "TEMP FILE", temp_file, temp_file.path

    #This is the tricky part
    #Initialize the temp file as a zip file
    # Zip::OutputStream.open(tf) { |zos| }

    Zip::File.open(tf.path, Zip::File::CREATE) do |z|
      # files.each do |f|
      z.add(temp_file, temp_file.path)
      # end
    end

    #Read the binary data from the file
    zip_data = File.read(tf.path)

    send_data(zip_data, :type => 'application/zip', :filename => "tf")

    tf.close
    tf.unlink

    attr_accessor :record_pdf
  end

end