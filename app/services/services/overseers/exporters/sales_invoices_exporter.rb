class Services::Overseers::Exporters::SalesInvoicesExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

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

    @model = SalesInvoice
  end

  def call
    model.where(:created_at => start_at..end_at).order(invoice_number: :asc).each do |sales_invoice|
      sales_order = sales_invoice.sales_order
      inquiry = sales_invoice.inquiry
      rows.push({
                    :inquiry_number => sales_invoice.inquiry.inquiry_number.to_s,
                    :invoice_number => sales_invoice.invoice_number,
                    :invoice_date => sales_invoice.created_at.to_date.to_s,
                    :order_number => sales_invoice.sales_order.order_number.to_s,
                    :order_date => sales_invoice.sales_order.created_at.to_date.to_s,
                    :customer_name => sales_invoice.inquiry.company.name.to_s,
                    :invoice_net_amount => ('%.2f' % sales_order.calculated_total),
                    :freight_and_packaging => ('%.2f' % sales_order.calculated_freight_cost_total || sales_invoice.metadata['shipping_amount']),
                    :total_with_freight => ('%.2f' % sales_order.calculated_total), #cross-check
                    :tax_amount => ('%.2f' % sales_order.calculated_total_tax),
                    :gross_amount => ('%.2f' % sales_order.calculated_total_with_tax),
                    :bill_from_branch => (inquiry.bill_from.address.state.name if inquiry.bill_from.present?),
                    :invoice_status => sales_invoice.sales_order.remote_status
                })
    end

    generate_csv
  end
end