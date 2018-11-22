json.data (@po_requests) do |po_request|
  json.array! [
                  [
                      if policy(po_request).show?
                        row_action_button(overseers_po_request_path(po_request), 'eye', 'View PO Request', 'info')
                      end,
                      if policy(po_request).edit?
                        row_action_button(edit_overseers_po_request_path(po_request), 'pencil', 'Edit PO Request', 'warning')
                      end
                  ].join(' '),
                  po_request.id,
                  format_date_time_meridiem(po_request.created_at),
                  po_request.inquiry.inquiry_number,
                  po_request.sales_order.order_number,
                  po_request.inquiry.inside_sales_owner.to_s,
                  po_request.status
              ]
end

json.recordsTotal @po_requests.model.all.count
json.recordsFiltered @po_requests.count
json.draw params[:draw]