class RenderCsvToFile < BaseFunction
  def self.for(record, locals={})

    filename = [record.name, 'pending_payments'].join('-')
    path = Rails.root.join('tmp', 'payment_collections')
    columns = [
        'Sr No.',
        'Name Of Entity',
        'Amount Invoiced',
        'Name Amount Received',
        'Amount Outstanding'
    ]

    csv_data = CSV.generate(write_headers: true, headers: columns) do |csv|
      record.companies.with_invoices.each_with_index do |company, index|
        csv << [index + 1, company.name, company.total_amount_due, company.total_amount_received, company.total_amount_outstanding]
      end
    end

    tempfile = Tempfile.new([filename, 'csv'].join('.'), Rails.root.join('tmp'))
    tempfile.binmode
    tempfile.write csv_data
    tempfile.close

    tempfile.path

  end
end
