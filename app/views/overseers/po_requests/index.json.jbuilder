json.data (@po_requests) do |po_request|
  json.array! [
                  [
                      if policy(po_request).show?
                        row_action_button(overseers_po_request_path(po_request), 'eye', 'View PO Request', 'info')
                      end,
                      if policy(po_request).edit?
                        row_action_button(edit_overseers_po_request_path(po_request), 'pencil', 'Edit PO Request', 'warning')
                      end,
                      if policy(po_request).new_payment_request?
                        row_action_button(new_overseers_po_request_payment_request_path(po_request), 'dollar-sign', 'Payment Request', 'success', :_blank)
                      elsif policy(po_request).show_payment_request?
                        row_action_button(overseers_payment_request_path(po_request.payment_request), 'eye', 'View Payment Request', 'success')
                      end,
                      if policy(po_request).sending_po_to_supplier_new_email_message?
                        row_action_button(sending_po_to_supplier_overseers_po_request_email_messages_path(po_request), 'envelope', 'Send Purchase order to supplier', 'dark', :_blank)
                      end,
                      if policy(po_request).dispatch_supplier_delayed_new_email_message?
                        row_action_button(dispatch_from_supplier_delayed_overseers_po_request_email_messages_path(po_request), 'envelope', 'Dispatch from supplier delayed', 'dark', :_blank)
                      end
                  ].join(' '),
                  po_request.id,
                  status_badge(po_request.status),
                  conditional_link(po_request.inquiry.inquiry_number, edit_overseers_inquiry_path(po_request.inquiry), policy(po_request.inquiry).edit?),
                  conditional_link(po_request.sales_order.order_number, overseers_inquiry_sales_order_path(po_request.inquiry, po_request.sales_order), policy(po_request.sales_order).show?),
                  if po_request.logistics_owner.present?
                    po_request.logistics_owner.to_s
                  end,
                  po_request.inquiry.inside_sales_owner.to_s,
                  format_date_time_meridiem(po_request.created_at),
                  if po_request.last_comment.present?
                    format_date_time_meridiem(po_request.last_comment.updated_at)
                  end,
                  status_badge(po_request.purchase_order.has_sending_po_to_supplier_email_messages? ? "Supplier PO Sent" : "Supplier PO: Not Sent to Supplier"),
                  if po_request.last_comment.present?
                    format_comment(po_request.last_comment, trimmed: true)
                  end
              ]
end

json.recordsTotal @po_requests.count
json.recordsFiltered @po_requests.total_count
json.draw params[:draw]