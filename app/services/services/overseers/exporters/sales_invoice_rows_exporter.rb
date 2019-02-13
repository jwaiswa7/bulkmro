class Services::Overseers::Exporters::SalesInvoiceRowsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize
    super
    @model = SalesInvoiceRow
    @export_name = "sales_invoice_rows"
    @path = Rails.root.join("tmp", filename)
    @columns = [
        "Inquiry Number",
        "BM Number",
        "Invoice Number",
        "Invoice Date",
        "Order Number",
        "Order Date",
        "Customer Name",
        "Invoice Net Amount",
        "Freight / Packing",
        "Total Net Amount Including Freight",
        "Invoice Tax Amount",
        "Invoice Gross Amount",
        "Branch (Bill From)",
        "Invoice Status"
    ]
  end

  def call
    perform_export_later("SalesInvoiceRowsExporter")
  end

  def build_csv
    model.where(created_at: start_at..end_at).order(sales_invoice_id: :asc).where("sales_invoices.sales_order_id IS NOT NULL").joins(:sales_invoice).each do |row|
      sales_invoice = row.sales_invoice
      sales_order = sales_invoice.sales_order
      inquiry = sales_invoice.inquiry
      rows.push(
        inquiry_number: sales_invoice.inquiry.inquiry_number.to_s,
        bm_number: row.sku,
        invoice_number: sales_invoice.invoice_number,
        invoice_date: sales_invoice.created_at.to_date.to_s,
        order_number: sales_invoice.sales_order.order_number.to_s,
        order_date: sales_invoice.sales_order.created_at.to_date.to_s,
        customer_name: sales_invoice.inquiry.company.name.to_s,
        invoice_net_amount: ("%.2f" % (sales_order.calculated_total_cost - sales_invoice.metadata["shipping_amount"].to_f)) || "%.2f" % sales_order.calculated_total_cost_without_freight,
        freight_and_packaging: (sales_invoice.metadata["shipping_amount"] || "%.2f" % sales_order.calculated_freight_cost_total),
        total_with_freight: ("%.2f" % sales_order.calculated_total), # cross-check
        tax_amount: ("%.2f" % sales_order.calculated_total_tax),
        gross_amount: ("%.2f" % sales_order.calculated_total_with_tax),
        bill_from_branch: if inquiry.bill_from then inquiry.bill_from.address.state.name else "" end,
        invoice_status: sales_invoice.sales_order.remote_status
                )
    end
    export = Export.create!(export_type: 20)
    generate_csv(export)
  end
end
