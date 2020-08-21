class Services::Overseers::SalesInvoices::Zipped < Services::Shared::BaseService
  def initialize(record, locals)
    @record = record
    @locals = locals
  end

  def call
    date = Date.parse(record.metadata['created_at'])
    year = date.year
    year = year - 1 if date.month < 4
    if record.inquiry.is_sez? || record.serialized_billing_address.country_code != 'IN'
      if record.metadata['created_at'].present? && Settings.accounts.try("arn_date_#{year}").present? && Date.parse(Settings.accounts.try("arn_date_#{year}")) <= Date.parse(record.metadata['created_at'])
        arn_date = Date.parse(Settings.accounts.try("arn_date_#{year}"))
        arn_number = Settings.accounts.try("arn_number_#{year}")
      else
        arn_date = Date.parse(Settings.accounts.try('arn_date_2018'))
        arn_number = Settings.accounts.try('arn_number_2018')
      end
    end
    files = [
        { name: "original_#{record.filename}.pdf", path: RenderPdfToFile.for(record, locals.merge(arn_date: arn_date, arn_number: arn_number)) },
        { name: "duplicate_#{record.filename}.pdf", path: RenderPdfToFile.for(record, locals.merge(duplicate: true, arn_date: arn_date, arn_number: arn_number)) },
        { name: "triplicate_#{record.filename}.pdf", path: RenderPdfToFile.for(record, locals.merge(triplicate: true, arn_date: arn_date, arn_number: arn_number)) }
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
