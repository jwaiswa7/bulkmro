json.data (@sales_invoices) do |sales_invoice|
  json.array! [
                  [
                      row_action_button(overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                  ].join(' '),
                  sales_invoice.invoice_number,
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.inquiry_number: "",
                  sales_invoice.inquiry.present? ? sales_invoice.sales_order.order_number: "",
                  sales_invoice.inquiry.present? ? sales_invoice.rows.count: "",
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.inside_sales_owner.to_s: "",
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.outside_sales_owner.to_s: "",
                  format_date(sales_invoice.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       []
                   ]

json.recordsTotal SalesInvoice.all.count
json.recordsFiltered @indexed_sales_invoices.total_count
json.draw params[:draw]

