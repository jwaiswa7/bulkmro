class Services::Overseers::Exporters::SalesInvoicesExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(headers)
    @file_name = 'sales_invoices'
    super(headers, @file_name)
    @model = SalesInvoice
    @columns = [
        'Inquiry Number',
        'Invoice Number',
        'Invoice Date',
        'Order Number',
        'Order Date',
        'Customer Name',
        'Invoice Net Amount',
        'Freight / Packing',
        'Total Net Amount Including Freight',
        'Invoice Tax Amount',
        'Invoice Gross Amount',
        'Branch (Bill From)',
        'Invoice Status'
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
      model.where(created_at: start_at..end_at).where.not(sales_order_id: nil).where.not(metadata: nil).order(invoice_number: :asc).each do |sales_invoice|
        sales_order = sales_invoice.sales_order
        inquiry = sales_invoice.inquiry
        rows.push(
          inquiry_number: sales_invoice.inquiry.inquiry_number.to_s,
          invoice_number: sales_invoice.invoice_number,
          invoice_date: sales_invoice.created_at.to_date.to_s,
          order_number: sales_invoice.sales_order.order_number.to_s,
          order_date: sales_invoice.sales_order.created_at.to_date.to_s,
          customer_name: sales_invoice.inquiry.company.name.to_s,
          invoice_net_amount: (('%.2f' % (sales_order.calculated_total_cost.to_f - sales_invoice.metadata['shipping_amount'].to_f)) || '%.2f' % sales_order.calculated_total_cost_without_freight),
          freight_and_packaging: (sales_invoice.metadata['shipping_amount'] || '%.2f' % sales_order.calculated_freight_cost_total),
          total_with_freight: ('%.2f' % sales_invoice.metadata['subtotal'] if sales_invoice.metadata['subtotal']),
          tax_amount: ('%.2f' % sales_invoice.metadata['tax_amount']),
          gross_amount: ('%.2f' % sales_invoice.metadata['grand_total']),
          bill_from_branch: (inquiry.bill_from.address.state.name if inquiry.bill_from.present?),
          invoice_status: sales_invoice.sales_order.remote_status
                  )
      end
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end
