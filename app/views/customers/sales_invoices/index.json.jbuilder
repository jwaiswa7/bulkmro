json.data (@sales_invoices) do |sales_invoice|
  json.array! [
                  [
                      if policy(sales_invoice).show?
                        row_action_button(customers_invoice_path(sales_invoice), 'eye', 'View Invoice', 'info')
                      end,
                      if policy(sales_invoice).show?
                        row_action_button(customers_invoice_path(sales_invoice, stamp: 1, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if policy(sales_invoice).show_original_invoice? && sales_invoice.inquiry.present?
                        row_action_button(url_for(sales_invoice.original_invoice), 'file-pdf', sales_invoice.original_invoice.filename, 'dark', :_blank)
                      end,
                      # if policy(sales_invoice).edit_pod? && sales_invoice.pod_attachments.attached?
                      #   [
                      #       if sales_invoice.pod_attachments.attached?; row_action_button(url_for(sales_invoice.pod_attachments), 'certificate', 'Download Proof of Delivery', 'success', :_blank); end
                      #   ]
                      #end
                  ].join(' '),
                  sales_invoice.inquiry.customer_po_number,
                  format_date(sales_invoice.inquiry.customer_order_date),
                  sales_invoice.invoice_number,
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.inquiry_number : '',
                  sales_invoice.inquiry.present? ? sales_invoice.sales_order.order_number : '',
                  sales_invoice.inquiry.present? ? sales_invoice.rows.count : '',
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.inside_sales_owner.to_s : '',
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.outside_sales_owner.to_s : '',
                  format_date(sales_invoice.delivery_date),
                  format_date(sales_invoice.created_at)
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
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal SalesInvoice.all.count
json.recordsFiltered @indexed_sales_invoices.total_count
json.draw params[:draw]
