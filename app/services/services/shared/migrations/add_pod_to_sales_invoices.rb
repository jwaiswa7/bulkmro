class Services::Shared::Migrations::AddPodToSalesInvoices < Services::Shared::Migrations::MigrationsV2
  def pod_attachment_to_sales_invoices
    service = Services::Shared::Spreadsheets::CsvImporter.new('payment_received.csv', 'seed_files')
    headers = ['Branch', 'Invoice Number', 'Customer Name', 'Date']
    csv_data = CSV.generate(write_headers: true, headers: headers) do |writer|
      service.loop(nil) do |x|
        invoice_number = x.get_column('Invoice No.')
        delivery_date = x.get_column('Date')
        customer_name = x.get_column('Customer')
        branch = x.get_column('Branch')
        sales_invoice = SalesInvoice.where(invoice_number: invoice_number).last
        if sales_invoice.present?
          pod_row = sales_invoice.pod_rows.build(delivery_date: delivery_date)
          pod_row.attachments.attach(io: File.open("#{Rails.root}/lib/assets/pod_attachments/dummy_pod.pdf"), filename: 'dummy_pod.pdf')
          pod_row.save!
        else
          writer << [ branch, invoice_number, customer_name, delivery_date ]
        end
        puts invoice_number
      end
    end
    fetch_csv('missing_sales_invoices.csv', csv_data)
  end
end
