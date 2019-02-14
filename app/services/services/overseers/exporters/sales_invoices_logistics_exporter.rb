class Services::Overseers::Exporters::SalesInvoicesLogisticsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize
    super
    @model = SalesInvoice
    @export_name = 'sales_invoice_logistics'
    @path = Rails.root.join('tmp', filename)
    @columns = %w(inquiry_number inquiry_date company_name inside_sales order_number order_date order_status invoice_number invoice_date committed_customer_date)
  end

  def call
    perform_export_later('SalesInvoicesLogisticsExporter')
  end

  def build_csv
    model.where(created_at: start_at..end_at).where.not(sales_order_id: nil).where.not(metadata: nil).order(invoice_number: :asc).each do |sales_invoice|
      rows.push(
        inquiry_number: sales_invoice.inquiry.inquiry_number.to_s,
        inquiry_date: sales_invoice.inquiry.created_at.to_date.to_s,
        company_name: sales_invoice.inquiry.company.name.to_s,
        inside_sales: (sales_invoice.inquiry.inside_sales_owner.present? ? sales_invoice.inquiry.inside_sales_owner.try(:full_name) : nil),
        order_number: sales_invoice.sales_order.order_number.to_s,
        order_date: sales_invoice.sales_order.created_at.to_date.to_s,
        order_status: sales_invoice.sales_order.remote_status,
        invoice_number: sales_invoice.invoice_number,
        invoice_date: sales_invoice.created_at.to_date.to_s,
        committed_customer_date: (sales_invoice.inquiry.customer_committed_date.present? ? sales_invoice.inquiry.customer_committed_date.to_date.to_s : nil)
                )
    end
    export = Export.create!(export_type: 30)
    generate_csv(export)
  end
end
