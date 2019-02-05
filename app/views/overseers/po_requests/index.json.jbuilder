json.data (@po_requests) do |po_request|
  json.array! [
                  [
                      if (policy(po_request).edit? && po_request.status != 'Cancelled')
                        row_action_button(edit_overseers_po_request_path(po_request), 'pencil', 'Edit PO Request', 'warning')
                      end,
                      if policy(po_request).new_payment_request?
                        row_action_button(new_overseers_po_request_payment_request_path(po_request), 'dollar-sign', 'Payment Request', 'success', :_blank)
                      elsif policy(po_request).show_payment_request?
                        row_action_button(overseers_payment_request_path(po_request.payment_request), 'eye', 'View Payment Request', 'success')
                      end,
                      if policy(po_request).dispatch_supplier_delayed_new_email_message?
                        row_action_button(dispatch_from_supplier_delayed_overseers_po_request_email_messages_path(po_request), 'clock', 'Dispatch from Supplier Delayed', 'warning', :_blank)
                      end,
                      if policy(po_request).sending_po_to_supplier_new_email_message?
                        row_action_button(sending_po_to_supplier_overseers_po_request_email_messages_path(po_request), 'envelope', 'Send Purchase Order to Supplier', 'dark', :_blank)
                      end
                  ].join(' '),
                  conditional_link(po_request.id, overseers_po_request_path(po_request), policy(po_request).show?),
                  conditional_link(po_request.inquiry.inquiry_number, edit_overseers_inquiry_path(po_request.inquiry), policy(po_request.inquiry).edit?),
                  if po_request.purchase_order.present? && (po_request.status == 'PO Created')
                    po_request.purchase_order.po_number
                  else
                    po_request.sales_order.order_number if po_request.sales_order.present?
                  end,
                  po_request.inquiry.inside_sales_owner.to_s,
                  po_request.supplier.to_s,
                  po_request.buying_price,
                  po_request.selling_price,
                  po_request.po_margin_percentage,
                  po_request.sales_order.calculated_total_margin_percentage,
                  po_request.inquiry.customer_committed_date,
                  po_request.supplier_committed_date,
                  status_badge(po_request.status),
                  format_date_time_meridiem(po_request.created_at),
                  if po_request.last_comment.present?
                    format_date_time_meridiem(po_request.last_comment.updated_at)
                  end,
                  status_badge(po_request.try(:purchase_order).try(:has_sent_email_to_supplier?) ? "Supplier PO Sent" : "Supplier PO: Not Sent to Supplier"),
                  if po_request.last_comment.present?
                    format_comment(po_request.last_comment, trimmed: true)
                  end
              ]
end

json.recordsTotal @po_requests.count
json.recordsFiltered @po_requests.total_count
json.draw params[:draw]