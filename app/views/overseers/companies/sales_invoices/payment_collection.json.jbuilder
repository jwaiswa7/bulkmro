json.data (@sales_invoices) do |sales_invoice|
  json.array! [
                  [
                      if policy(sales_invoice).show? && sales_invoice.inquiry.present?
                        row_action_button(overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if sales_invoice.pod_attachment.attached?
                        row_action_button(url_for(sales_invoice.pod_attachment), 'certificate', 'Download Proof of Delivery', 'dark', :_blank)
                      end
                  ].join(' '),
                  @company.account.alias,
                  @company.name,
                  sales_invoice.inquiry.present? ? conditional_link(sales_invoice.inquiry.inquiry_number, edit_overseers_inquiry_path(sales_invoice.inquiry), policy(sales_invoice.inquiry).edit?) : '-',
                  sales_invoice.inquiry.present? ? conditional_link(sales_invoice.invoice_number, overseers_inquiry_sales_invoices_path(sales_invoice.inquiry), policy(sales_invoice).show?) : sales_invoice.invoice_number,
                  format_succinct_date(sales_invoice.mis_date),
                  '',
                  if  sales_invoice.sales_order.present? && sales_invoice.sales_order.inquiry.present? && sales_invoice.sales_order.inquiry.payment_option.present?
                    sales_invoice.sales_order.inquiry.payment_option.name
                  else
                    '-'
                  end,
                  format_currency(sales_invoice.calculated_total_with_tax || 0),
                  format_currency(sales_invoice.amount_received_against_invoice || 0),
                  format_currency((sales_invoice.calculated_total_with_tax - sales_invoice.amount_received_against_invoice) || 0),
                  format_date(sales_invoice.due_date),
                  sales_invoice.get_due_days,
                  if sales_invoice.inquiry.present?
                    sales_invoice.inquiry.customer_po_number
                  end,
                  if sales_invoice.inquiry.present?
                    sales_invoice.inquiry.customer_order_date
                  end,
                  if sales_invoice.inquiry.present?
                    sales_invoice.inquiry.contact.name
                  end,
                  if sales_invoice.inquiry.present? && sales_invoice.inquiry.shipping_contact.present?
                    sales_invoice.inquiry.shipping_contact.name
                  else
                    ''
                  end,
                  if sales_invoice.pod_attachment.attached?
                    format_succinct_date(sales_invoice.delivery_date)
                  else
                    '-'
                  end

  ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       # PaymentOption.all.map {|v| {"label": v.name, "value": v.id } }.as_json,
                       [{"source": autocomplete_overseers_payment_options_path}],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                   ]


json.recordsTotal @company.invoices.count
json.recordsFiltered @indexed_sales_invoices.total_count
json.draw params[:draw]
