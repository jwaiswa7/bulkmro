json.data (@sales_invoices) do |sales_invoice|
  json.array! [
                  [
                      if is_authorized(sales_invoice, 'show') && sales_invoice.inquiry.present?
                        [
                            row_action_button(overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice), 'eye', 'View Sales Invoice ', 'info', :_blank),
                            row_action_button(overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, stamp: 1, format: :pdf), 'none', 'Original with Signature', 'success', :_blank, 'get', false, 'O'),
                            row_action_button(make_zip_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, stamp: 1, format: :zip), 'stamp', 'Zip with Signature', 'info', :_blank),
                            row_action_button(make_zip_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, format: :zip), 'file-archive', 'Zip without Signature', 'info', :_blank)
                        ]
                      end,
                      if is_authorized(sales_invoice, 'show_original_invoice') && sales_invoice.inquiry.present?
                        [row_action_button(url_for(sales_invoice.original_invoice), 'none', sales_invoice.original_invoice.filename, 'success', :_blank, 'get', false, 'O'),
                         row_action_button(url_for(sales_invoice.duplicate_invoice), 'none', sales_invoice.duplicate_invoice.filename, 'success', :_blank, 'get', false, 'D'),
                         row_action_button(url_for(sales_invoice.triplicate_invoice), 'none', sales_invoice.triplicate_invoice.filename, 'success', :_blank, 'get', false, 'T'),
                        ]
                      end,
                      if is_authorized(sales_invoice, 'edit_pod') && (sales_invoice.pod_rows.count == 0)
                        row_action_button(edit_pod_overseers_sales_invoice_path(sales_invoice), 'truck', 'Add Proof of Delivery', 'success')
                      end,
                      if is_authorized(sales_invoice, 'edit_pod') && (sales_invoice.pod_rows.count > 0)
                        row_action_button(edit_pod_overseers_sales_invoice_path(sales_invoice), 'pencil', 'Edit Proof of Delivery', 'info')
                      end,
                      if is_authorized(sales_invoice, 'edit_mis_date')
                        row_action_button(edit_mis_date_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice), 'calendar-alt', 'Update MIS Date', 'success')
                      end,
                  ].join(' '),
                  conditional_link(sales_invoice.invoice_number, overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice), is_authorized(sales_invoice, 'show')),
                  sales_invoice.inquiry.present? ?  conditional_link(sales_invoice.inquiry.inquiry_number, edit_overseers_inquiry_path(sales_invoice.inquiry), is_authorized(sales_invoice.inquiry, 'edit')) : '-',
                  sales_invoice.inquiry.present? ?  conditional_link(sales_invoice.sales_order.order_number, overseers_inquiry_sales_order_path(sales_invoice.inquiry, sales_invoice.sales_order), is_authorized(sales_invoice.sales_order, 'show')) : '-',
                  # sales_invoice.inquiry.company.name,
                  link_to(sales_invoice.inquiry.company.name, overseers_company_path(sales_invoice.inquiry.company, sales_invoice), target: '_blank'),
                  sales_invoice.inquiry.present? ? sales_invoice.rows.count : '',
                  status_badge(sales_invoice.status),
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.inside_sales_owner.to_s : '',
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.outside_sales_owner.to_s : '',
                  format_succinct_date(sales_invoice.delivery_date),
                  format_succinct_date(sales_invoice.mis_date),
                  format_succinct_date(sales_invoice.created_at)
              ]
end

json.recordsTotal SalesInvoice.all.count
json.recordsFiltered @indexed_sales_invoices.total_count
json.draw params[:draw]
