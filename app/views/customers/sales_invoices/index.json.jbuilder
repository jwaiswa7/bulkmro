json.data (@sales_invoices) do |sales_invoice|
  json.array! [
                  [
                      if policy(sales_invoice).show? && !is_api_request?
                        row_action_button(customers_invoice_path(sales_invoice), 'eye', 'View Invoice', 'info')
                      end,
                      if policy(sales_invoice).show? && !is_api_request?
                        row_action_button(customers_invoice_path(sales_invoice, stamp: 1, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if policy(sales_invoice).show_original_invoice? && sales_invoice.inquiry.present? && !is_api_request?
                        row_action_button(url_for(sales_invoice.original_invoice), 'file-pdf', sales_invoice.original_invoice.filename, 'dark', :_blank)
                      end,
                      if policy(sales_invoice).show_pods? && sales_invoice.pod_rows.present? && !is_api_request?
                        row_action_button(show_pods_customers_invoice_path(sales_invoice), 'eye', "View POD's", 'success', :_blank)
                      end
                  ].join(' '),
                  sales_invoice.inquiry.customer_po_number,
                  format_date(sales_invoice.inquiry.customer_order_date),
                  sales_invoice.invoice_number,
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.inquiry_number : '',
                  sales_invoice.inquiry.shipping_contact.try(:name) || sales_invoice.inquiry.billing_contact.try(:name),
                  sales_invoice.inquiry.present? ? sales_invoice.sales_order.order_number : '',
                  sales_invoice.inquiry.present? ? sales_invoice.rows.count : '',
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.inside_sales_owner.to_s : '',
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.outside_sales_owner.to_s : '',
                  format_succinct_date(sales_invoice.delivery_date),
                  format_boolean_with_badge(sales_invoice.pod_status),
                  format_succinct_date(sales_invoice.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [{ "source": autocomplete_overseers_company_contacts_path(current_company) }],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal SalesInvoice.all.count
json.recordsFiltered @indexed_sales_invoices.total_count
json.draw params[:draw]
