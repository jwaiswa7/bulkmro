class RenderCsvToFile < BaseFunction
  def self.for(record, locals={})
    class_name = record.class.name
    filename = [record.name, 'pending_payments'].join('-')
    path = Rails.root.join('tmp', 'payment_collections')
    csv_data = []
    if class_name == 'Account'
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
    elsif
      columns = [
          'Sr No.',
          'Name Of Entity',
          'Invoice No',
          'Invoice Date',
          'Customer PO No.',
          'GRN No.',
          'Amount Invoiced',
          'Amount Received',
          'Amount Outstanding',
          'No. of Days Outstanding',
          'Bill To Name',
          'Ship To Name'
      ]
      csv_data = CSV.generate(write_headers: true, headers: columns) do |csv|
        record.invoices.not_cancelled_invoices.not_paid.each_with_index do |invoice, index|
          csv << [
          index+1,
          invoice.sales_order.company,
          invoice.invoice_number,
          invoice.created_date,
          invoice.inquiry.customer_po_number,
          '-',
          invoice.calculated_total_with_tax,
          invoice.amount_received,
          invoice.calculated_total_with_tax - invoice.amount_received,
          invoice.get_due_days,
          invoice.inquiry.contact.full_name,
          invoice.inquiry.shipping_contact.present? ? invoice.inquiry.shipping_contact.full_name : invoice.inquiry.contact.full_name
          ]
        end
      end
    end

    tempfile = Tempfile.new([filename, 'csv'].join('.'), Rails.root.join('tmp'))
    tempfile.binmode
    tempfile.write csv_data
    tempfile.close

    tempfile.path

  end
end
