class Services::Overseers::OutwardDispatches::Zipped < Services::Shared::BaseService
  def initialize(record, locals)
    @record = record
    @locals = locals

  end

  def call
    files = []
    record.each_with_index do |packing_slip,i|
      files <<  { name: "#{packing_slip.outward_dispatch.ar_invoice_request.ar_invoice_number}-#{i + 1}.pdf", path: RenderPdfToFile.for(packing_slip, locals: {packing_slip: packing_slip, inquiry: packing_slip.outward_dispatch.sales_order.inquiry} ) }
    end

    packing_zip = Rails.root.join('tmp', 'archive.zip')
    Zip::OutputStream.open(packing_zip) { |os| }
    Zip::File.open(packing_zip, Zip::File::CREATE) do |zip_file|
      files.each do |file|
        unless File.exist?(file[:path])
          locals_values = locals
          file = { name: "#{packing_slip.outward_dispatch.ar_invoice_request.ar_invoice_number}-#{i + 1}.pdf", path: RenderPdfToFile.for(packing_slip, locals_values ) }

        end
        zip_file.add(file[:name], File.join(Rails.root.join('tmp'), File.basename(file[:path])))
      end
    end
    File.read(packing_zip)
  end

  attr_accessor :record, :locals
end
