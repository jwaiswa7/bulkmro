class Services::Customers::Exporters::SalesInvoicesExporter < Services::Customers::Exporters::BaseExporter
  def initialize(headers, company)
    @filename = 'sales_invoices_for_customer'
    super(headers, @filename)
    @company = company
    @model = SalesInvoice
    @columns = [
        'Inquiry Number',
        'Invoice Number',
        'Invoice Date',
        'Order Number',
        'Order Date',
        'Customer Name',
        'Invoice Net Amount',
        'Invoice Tax Amount',
        'Invoice Gross Amount',
        'Invoice Status',
        'POD Status'
    ]
    @columns.each do |column|
      rows.push(column)
    end
  end

  def call
    build_csv
  end

  def build_csv
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(rows)
      model.where.not(sales_order_id: nil, metadata: nil).joins(:inquiry).where('inquiries.company_id = ?', company.id).where(created_at: @start_at..@end_at).order(invoice_number: :asc).each do |sales_invoice|
        rows.push(
          inquiry_number: sales_invoice.inquiry.inquiry_number.to_s,
          invoice_number: sales_invoice.invoice_number,
          invoice_date: sales_invoice.created_at.to_date.to_s,
          order_number: sales_invoice.sales_order.order_number.to_s,
          order_date: sales_invoice.sales_order.created_at.to_date.to_s,
          customer_name: sales_invoice.inquiry.company.name.to_s,
          invoice_net_amount: ('%.2f' % sales_invoice.metadata['subtotal'] if sales_invoice.metadata['subtotal']),
          tax_amount: ('%.2f' % sales_invoice.metadata['tax_amount'] if sales_invoice.metadata['tax_amount']),
          gross_amount: ('%.2f' % sales_invoice.metadata['grand_total'] if sales_invoice.metadata['grand_total']),
          invoice_status: sales_invoice.sales_order.remote_status,
          pod_status: sales_invoice.pod_status
                  )
      end
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end
