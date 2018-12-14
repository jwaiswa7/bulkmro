json.data (@payment_requests) do |payment_request|
  json.array! [
                  [
                      if policy(payment_request).show?
                        row_action_button(overseers_payment_request_path(payment_request), 'eye', 'View Invoice Request', 'info')
                      end,
                      if policy(payment_request).edit?
                        row_action_button(edit_overseers_payment_request_path(payment_request), 'pencil', 'Edit Invoice Request', 'warning')
                      end
                  ].join(' '),
                  payment_request.id,
                  payment_request_status_badge(payment_request.status),
                  payment_request.inquiry.inquiry_number,
                  payment_request.po_request.purchase_order.id,
                  if payment_request.payment_option.present?
                    payment_request.payment_option.name
                  end,
                  payment_request.inquiry.inside_sales_owner.to_s,
                  format_date_time_meridiem(payment_request.due_date),
                  format_date_time_meridiem(payment_request.created_at),
                  if payment_request.last_comment.present?
                    format_date_time_meridiem(payment_request.last_comment.created_at)
                  end,
                  if payment_request.last_comment.present?
                    format_comment(payment_request.last_comment, trimmed: true)
                  end
              ]
end

=begin
json.columnFilters [
                       [],
                       [],
                       [],
                       # InvoiceRequest.statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       [],
                       [],
                       [],
                       []
                   ]
=end

json.recordsTotal @payment_requests.model.all.count
json.recordsFiltered @payment_requests.count
json.draw params[:draw]