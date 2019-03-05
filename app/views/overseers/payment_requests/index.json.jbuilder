json.data (@payment_requests) do |payment_request|
  json.array! [
                  [
                      if policy(payment_request).show?
                        row_action_button(overseers_payment_request_path(payment_request), 'eye', 'View Payment Request', 'info')
                      end,
                      if policy(payment_request).edit? && !payment_request.Cancelled?
                        row_action_button(edit_overseers_po_request_payment_request_path(payment_request.po_request, payment_request), 'pencil', 'Edit Payment Request', 'warning')
                      end
                  ].join(' '),
                  payment_request.id,
                  status_badge(payment_request.status),
                  link_to(payment_request.inquiry.inquiry_number, edit_overseers_inquiry_path(payment_request.inquiry), target: '_blank'),
                  link_to(payment_request.po_request.purchase_order.present? ? payment_request.po_request.purchase_order.to_s : '-', overseers_po_request_path(payment_request.po_request), target: '_blank'),
                  payment_request.request_owner,
                  # if payment_request.payment_type.present?
                  #   payment_request.payment_type
                  # end,
                  # if payment_request.utr_number.present?
                  #   payment_request.utr_number
                  # end,
                  payment_request.inquiry.inside_sales_owner.to_s,
                  if payment_request.due_date.present?
                    if payment_request.status == 'Partial Payment Pending' || payment_request.status == 'Payment Pending'
                      [format_due_distance(payment_request.due_date), format_date(payment_request.due_date)].join(' ')
                    else
                      format_date(payment_request.due_date)
                    end
                  else
                    '-'
                  end,
                  format_currency(payment_request.po_request.purchase_order.present? ? payment_request.po_request.purchase_order.try(:calculated_total_with_tax) : 0),
                  format_currency(payment_request.remaining_amount),
                  percentage(payment_request.percent_amount_paid, precision: 2),
                  format_date_time_meridiem(payment_request.updated_at),
                  if payment_request.last_comment.present?
                    format_succinct_date(payment_request.last_comment.created_at)
                  end,
                  if payment_request.last_comment.present?
                    format_comment(payment_request.last_comment, trimmed: true)
                  end
              ]
end


json.columnFilters [
                       [],
                       [],
                       PaymentRequest.statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]


json.recordsTotal @payment_requests.model.all.count
json.recordsFiltered @payment_requests.count
json.draw params[:draw]
json.recordsSummary PaymentRequest.statuses.map { |k, v| { status_id: v, "label": k, "size": @statuses[k] || 0 } }.as_json
