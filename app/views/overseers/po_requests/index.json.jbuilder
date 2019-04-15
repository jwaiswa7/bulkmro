json.data (@po_requests) do |po_request|
  json.array! [
                  [
                      if po_request.sales_order.present? && (policy(po_request).edit?)
                        row_action_button(edit_overseers_po_request_path(po_request), 'pencil', 'Edit PO Request', 'warning')
                      elsif policy(po_request).edit? && po_request.status != 'Cancelled'
                        row_action_button(edit_overseers_inquiry_po_request_path(po_request.inquiry, po_request), 'pencil', 'Edit PO Request', 'warning')
                      end,
                      if policy(po_request).new_payment_request?
                        row_action_button(new_overseers_po_request_payment_request_path(po_request), 'dollar-sign', 'Payment Request', 'success', :_blank)
                      elsif policy(po_request).show_payment_request?
                        row_action_button(overseers_payment_request_path(po_request.payment_request), 'eye', 'View Payment Request', 'info', :_blank)
                      end,
                      if policy(po_request).sending_po_to_supplier_new_email_message? && current_overseer.smtp_password.present?
                        row_action_button(sending_po_to_supplier_overseers_po_request_email_messages_path(po_request), 'envelope', 'Send Purchase Order to Supplier', 'dark', :_blank)
                      else
                        row_action_button(sending_po_to_supplier_overseers_po_request_email_messages_path(po_request), 'envelope', 'Enter SMTP settings', 'dark disabled')
                      end,
                      if policy(po_request).dispatch_supplier_delayed_new_email_message? && current_overseer.smtp_password.present?
                        row_action_button(dispatch_from_supplier_delayed_overseers_po_request_email_messages_path(po_request), 'envelope', 'Dispatch from Supplier Delayed', 'success', :_blank)
                      else
                        row_action_button(dispatch_from_supplier_delayed_overseers_po_request_email_messages_path(po_request), 'envelope', 'Enter SMTP settings', 'success disabled')
                      end,
                      if policy(po_request).material_received_in_bm_warehouse_new_email_msg? && current_overseer.smtp_password.present?
                        row_action_button(material_received_in_bm_warehouse_overseers_po_request_email_messages_path(po_request), 'envelope', 'Material Received in BM Warehouse', 'warning', :_blank)
                      else
                        row_action_button(material_received_in_bm_warehouse_overseers_po_request_email_messages_path(po_request), 'envelope', 'Enter SMTP settings', 'warning disabled')
                      end,
                      if policy(po_request).can_cancel?
                        link_to('', class: ['btn btn-sm btn-danger cancel-po_request'], 'data-po-request-id': po_request.id, title: 'Cancel', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      elsif po_request.po_request_type == "Stock" && !po_request.stock_status.downcase.include?('reject') && policy(po_request).can_reject?
                        link_to('', class: ['btn btn-sm btn-danger cancel-po_request'], 'data-po-request-id': po_request.id, title: 'Reject', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      else !po_request.status.downcase.include?('reject') && policy(po_request).can_reject?
                        link_to('', class: ['btn btn-sm btn-danger cancel-po_request'], 'data-po-request-id': po_request.id, title: 'Reject', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      end
                  ].join(' '),
                  conditional_link(po_request.id, overseers_po_request_path(po_request), policy(po_request).show?),
                  status_badge(po_request.status),
                  conditional_link(po_request.inquiry.to_s, edit_overseers_inquiry_path(po_request.inquiry), policy(po_request.inquiry).edit?),
                  if po_request.purchase_order.present? && (po_request.status == 'Supplier PO: Created Not Sent')
                    link_to(po_request.purchase_order.po_number, overseers_inquiry_purchase_order_path(po_request.inquiry, po_request.purchase_order), target: '_blank')

                  else
                    po_request.sales_order.order_number if po_request.sales_order.present?
                  end,
                  po_request.inquiry.inside_sales_owner.to_s,
                  if po_request.supplier.present?
                    conditional_link(po_request.supplier.to_s, overseers_company_path(po_request.supplier), policy(po_request.supplier).show?)
                  end,
                  po_request.buying_price,
                  po_request.selling_price,
                  po_request.po_margin_percentage,
                  (po_request.sales_order.calculated_total_margin_percentage if po_request.sales_order.present?),
                  format_date(po_request.inquiry.customer_committed_date),
                  format_date(po_request.supplier_committed_date),
                  format_date_time_meridiem(po_request.created_at),
                  if po_request.last_comment.present?
                    format_succinct_date(po_request.last_comment.updated_at)
                  end,
                  status_badge(po_request.try(:purchase_order).try(:has_sent_email_to_supplier?) ? 'Supplier PO Sent' : 'Supplier PO: Not Sent to Supplier'),
                  if po_request.last_comment.present?
                    format_comment(po_request.last_comment, trimmed: true)
                  end
              ]
end

json.recordsTotal @po_requests.count
json.recordsFiltered @po_requests.total_count
json.draw params[:draw]
