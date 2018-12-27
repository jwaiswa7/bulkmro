json.data (@freight_requests) do |freight_request|
  json.array! [
                  [
                      if policy(freight_request).show?
                        row_action_button(overseers_freight_request_path(freight_request), 'eye', 'View Freight Request', 'info')
                      end,
                      row_action_button(edit_overseers_freight_request_path(freight_request), 'pencil', 'Edit Freight Request', 'warning'),
                      if freight_request.freight_quote.present? && policy(:freight_quote).show?
                        row_action_button(overseers_freight_quote_path(freight_request.freight_quote), 'eye', 'View Freight Quote', 'primary')
                      end,
                      if freight_request.freight_quote.present? && policy(:freight_quote).edit?
                        row_action_button(edit_overseers_freight_request_freight_quote_path(freight_request, freight_request.freight_quote), 'pencil', 'Edit Freight Quote', 'success')
                      end,
                  ].join(' '),
                  freight_request.id,
                  status_badge(freight_request.status),
                  freight_request.inquiry.inquiry_number,
                  freight_request.sales_order.order_number,
                  freight_request.inquiry.inside_sales_owner.to_s,
                  format_date_time_meridiem(freight_request.created_at),
                  if freight_request.last_comment.present?
                    format_date_time_meridiem(freight_request.last_comment.updated_at)
                  end,
                  if freight_request.last_comment.present?
                    format_comment(freight_request.last_comment, trimmed: true)
                  end
              ]
end

json.recordsTotal @freight_requests.count
json.recordsFiltered @freight_requests.total_count
json.draw params[:draw]