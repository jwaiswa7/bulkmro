class Services::Overseers::Exporters::SalesInvoicesLogisticsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(headers)
    @file_name = 'sales_invoice_logistics'
    super(headers, @file_name)
    @model = SalesInvoice
    @columns = %w(inquiry_number inquiry_date company_name inside_sales order_number order_date order_status invoice_number invoice_date committed_customer_date)
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
        rows.push(
                      inquiry_number: sales_invoice.inquiry.inquiry_number.to_s,
                      inquiry_date: sales_invoice.inquiry.created_at.to_date.to_s,
                      company_name: sales_invoice.inquiry.company.name.to_s,
                      inside_sales: ( sales_invoice.inquiry.inside_sales_owner.present? ? sales_invoice.inquiry.inside_sales_owner.try(:full_name) : nil ),
                      order_number: sales_invoice.sales_order.order_number.to_s,
                      order_date: sales_invoice.sales_order.created_at.to_date.to_s,
                      order_status: sales_invoice.sales_order.remote_status,
                      invoice_number: sales_invoice.invoice_number,
                      invoice_date: sales_invoice.created_at.to_date.to_s,
                      committed_customer_date: ( sales_invoice.inquiry.customer_committed_date.present? ? sales_invoice.inquiry.customer_committed_date.to_date.to_s : nil )
                  )
      end
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end
