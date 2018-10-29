class Services::Overseers::Exporters::SalesInvoicesExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

    @columns = %w(inquiry_number inquiry_date company_name order_number order_date order_status invoice_number invoice_date customer_po_number)
    @model = SalesInvoice
  end

  def call
    model.where(:created_at => start_at..end_at).each do |sales_invoice|
      rows.push({
                    :inquiry_number => sales_invoice.inquiry.inquiry_number.to_s,
                    :inquiry_date => sales_invoice.inquiry.created_at.to_date.to_s,
                    :company_name => sales_invoice.inquiry.company.name.to_s,
                    :order_number => sales_invoice.sales_order.order_number.to_s,
                    :order_date => sales_invoice.sales_order.created_at.to_date.to_s,
                    :order_status => sales_invoice.sales_order.remote_status,
                    :invoice_number => sales_invoice.invoice_number,
                    :invoice_date => sales_invoice.created_at.to_date.to_s,
                    :customer_po_number => sales_invoice.inquiry.customer_po_number,
                })
    end

    generate_csv
  end
end