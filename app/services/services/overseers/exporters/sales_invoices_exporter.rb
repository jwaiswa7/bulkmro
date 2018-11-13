class Services::Overseers::Exporters::SalesInvoicesExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

    @columns = %w(
        inquiry_number
        invoice_number
        invoice_date
        order_number
        order_date
        customer_name
        invoice_net_amount
        freight_and_packaging
        total_with_freight
        tax_amount
        gross_amount
        bill_from_branch
        invoice_status
    )
    @model = SalesInvoice
  end

  def call
    model.where(:created_at => start_at..end_at).order(invoice_number: :asc).each do |sales_invoice|
      sales_order = sales_invoice.sales_order
      rows.push({
                    :inquiry_number => sales_invoice.inquiry.inquiry_number.to_s,
                    :invoice_number => sales_invoice.invoice_number,
                    :invoice_date => sales_invoice.created_at.to_date.to_s,
                    :order_number => sales_invoice.sales_order.order_number.to_s,
                    :order_date => sales_invoice.sales_order.created_at.to_date.to_s,
                    :customer_name => sales_invoice.inquiry.company.name.to_s,
                    :invoice_net_amount => ('%.2f' % sales_order.calculated_total), #Doubt
                    :freight_and_packaging => ('%.2f' % sales_order.calculated_freight_cost_total), #Doubt
                    :total_with_freight => ('%.2f' % sales_order.calculated_total_cost), #Doubt
                    :tax_amount => ('%.2f' % sales_order.calculated_total_tax),
                    :gross_amount => ('%.2f' % sales_order.calculated_total_with_tax),
                    :bill_from_branch => sales_invoice.metadata['state'], #hasstateid
                    :invoice_status => sales_invoice.sales_order.remote_status
                })
    end

    generate_csv
  end
end