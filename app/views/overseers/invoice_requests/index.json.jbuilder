json.data (@invoice_requests) do |invoice_request|
  json.array! [
                  [
                      if policy(invoice_request).show?
                        row_action_button(overseers_invoice_request_path(invoice_request), 'eye', 'View Invoice Request', 'info')
                      end,
                      if policy(invoice_request).edit?
                        row_action_button(edit_overseers_invoice_request_path(invoice_request), 'pencil', 'Edit Invoice Request', 'warning')
                      end
                  ].join(' '),
                  invoice_request.id,
                  status_badge(invoice_request.status),
                  conditional_link(invoice_request.inquiry.inquiry_number, edit_overseers_inquiry_path(invoice_request.inquiry), policy(invoice_request.inquiry).edit?),
                  conditional_link(invoice_request.sales_order.order_number, overseers_inquiry_sales_order_path(invoice_request.inquiry, invoice_request.sales_order), policy(invoice_request.sales_order).show?),
                  invoice_request.inquiry.inside_sales_owner.to_s,
                  format_date_time_meridiem(invoice_request.created_at),
                  if invoice_request.last_comment.present?
                    format_date_time_meridiem(invoice_request.last_comment.created_at)
                  end,
                  if invoice_request.last_comment.present?
                    format_comment(invoice_request.last_comment, trimmed: true)
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

json.recordsTotal @invoice_requests.model.all.count
json.recordsFiltered @invoice_requests.count
json.draw params[:draw]
json.recordsSummary InvoiceRequest.statuses.map {|k, v| {:status_id => v ,:"label" => k, :"size" => @statuses.count(k)}}.as_json