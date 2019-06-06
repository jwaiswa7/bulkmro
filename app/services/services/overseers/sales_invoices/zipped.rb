class Services::Overseers::SalesInvoices::Zipped < Services::Shared::BaseService
  def initialize(record, locals)
    @record = record
    @locals = locals
  end

  def call
    files = [
        { name: "original_#{record.filename}.pdf", path: RenderPdfToFile.for(record, locals) },
        { name: "duplicate_#{record.filename}.pdf", path: RenderPdfToFile.for(record, locals.merge(duplicate: true)) },
        { name: "triplicate_#{record.filename}.pdf", path: RenderPdfToFile.for(record, locals.merge(triplicate: true)) }
    ]

    invoice_zip = Rails.root.join('tmp', 'archive.zip')

    Zip::OutputStream.open(invoice_zip) { |os| }

    Zip::File.open(invoice_zip, Zip::File::CREATE) do |zip_file|
      files.each do |file|
        unless File.exist?(file[:path])
          file_type = file[:name].split('_')[0]
          if file_type == 'triplicate'
            locals_values = locals.merge(triplicate: true)
          elsif file_type == 'duplicate'
            locals_values = locals.merge(duplicate: true)
          elsif file_type == 'original'
            locals_values = locals
          end
          file = { name: "#{file_type}_#{record.filename}.pdf", path: RenderPdfToFile.for(record, locals_values) }
        end
        zip_file.add((file[:name]), File.join(Rails.root.join('tmp'), File.basename(file[:path])))
      end
    end

    File.read(invoice_zip)
  end

  attr_accessor :record, :locals
end
