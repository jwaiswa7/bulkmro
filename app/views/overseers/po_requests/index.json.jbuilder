json.data (@po_requests) do |po_request|
  json.array! [
                  [
                      if policy(po_request).show?
                        row_action_button(overseers_po_request_path(po_request), 'eye', 'View PO Request', 'info')
                      end,
                      if policy(po_request).edit?
                        row_action_button(edit_overseers_po_request_path(po_request), 'pencil', 'Edit PO Request', 'warning')
                      end,
                      if policy(po_request).can_request_payment?
                        row_action_button(new_overseers_payment_request_path(:po_request_id => po_request.to_param), 'dollar-sign', 'Payment Request', 'success', :_blank)
                      end
                  ].join(' '),
                  po_request.id,
                  format_date_time_meridiem(po_request.created_at),
                  po_request.inquiry.inquiry_number,
                  po_request.sales_order.order_number,
                  po_request.inquiry.inside_sales_owner.to_s,
                  po_request.status,
                  po_request.last_comment.message
              ]
end

json.recordsTotal @po_requests.model.all.count
json.recordsFiltered @po_requests.count
json.draw params[:draw]