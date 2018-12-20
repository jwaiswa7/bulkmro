json.data (@sales_invoices) do |sales_invoice|
  json.array! [
                  [
                      if policy(sales_invoice).show? && sales_invoice.inquiry.present?
                        [row_action_button(overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, :stamp => 1, format: :pdf), 'file-pdf', 'Original with Signature', 'dark', :_blank),
                         row_action_button(duplicate_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, :stamp => 1, format: :pdf), 'file-pdf', 'Duplicate with Signature', 'dark', :_blank),
                         row_action_button(triplicate_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, :stamp => 1, format: :pdf), 'file-pdf', 'Triplicate with Signature', 'dark', :_blank),
                         row_action_button(make_zip_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, :stamp => 1, format: :zip), 'download', 'Zip with Signature', 'dark', :_blank),
                         row_action_button(make_zip_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, format: :zip), 'download', 'Zip without Signature', 'dark', :_blank)
                        ]
                      end,
                      if policy(sales_invoice).show_original_invoice? && sales_invoice.inquiry.present?
                        [row_action_button(url_for(sales_invoice.original_invoice), 'file-pdf', sales_invoice.original_invoice.filename, 'dark', :_blank),
                         row_action_button(url_for(sales_invoice.duplicate_invoice), 'file-pdf', sales_invoice.duplicate_invoice.filename, 'dark', :_blank),
                         row_action_button(url_for(sales_invoice.triplicate_invoice), 'file-pdf', sales_invoice.triplicate_invoice.filename, 'dark', :_blank),
                        ]
                      end,
                      if policy(sales_invoice).edit_pod? && !sales_invoice.pod_attachment.attached?
                        row_action_button(edit_pod_overseers_sales_invoice_path(sales_invoice), 'plus-circle', 'Add Proof of Delivery', 'success')
                      end,
                      if policy(sales_invoice).edit_pod? && sales_invoice.pod_attachment.attached?
                        [
                            if sales_invoice.pod_attachment.attached?;
                              row_action_button(url_for(sales_invoice.pod_attachment), 'certificate', 'Download Proof of Delivery', 'dark', :_blank);
                            end,
                            row_action_button(edit_pod_overseers_sales_invoice_path(sales_invoice), 'pencil', 'Edit Proof of Delivery', 'info')
                        ]
                      end,
                      if policy(sales_invoice).edit_mis_date?
                        row_action_button(edit_mis_date_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice), 'calendar-alt', 'Update MIS Date', 'success')
                      end,
                  ].join(' '),
                  sales_invoice.invoice_number,
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.inquiry_number : "",
                  sales_invoice.inquiry.present? ? sales_invoice.sales_order.order_number : "",
                  sales_invoice.inquiry.present? ? sales_invoice.rows.count : "",
                  sales_invoice.status,
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.inside_sales_owner.to_s : "",
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.outside_sales_owner.to_s : "",
                  format_date(sales_invoice.delivery_date),
                  format_date(sales_invoice.mis_date),
                  format_date(sales_invoice.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       SalesInvoice.statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       [],
                       [],
                       [],
                   ]

json.recordsTotal SalesInvoice.all.count
json.recordsFiltered @indexed_sales_invoices.total_count
json.draw params[:draw]