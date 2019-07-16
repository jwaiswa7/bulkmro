json.data (@invoice_requests) do |invoice_request|
  json.array! [
                  [
                      if is_authorized(invoice_request, 'show')
                        row_action_button(overseers_invoice_request_path(invoice_request), 'eye', 'View AP Request', 'info')
                      end,
                      if is_authorized(invoice_request, 'edit')
                        row_action_button(edit_overseers_invoice_request_path(invoice_request), 'pencil', "Edit #{invoice_request.readable_status}", 'warning')
                      end,
                      if !invoice_request.status.downcase.include?('cancel') && is_authorized(invoice_request, 'can_cancel_or_reject')
                        link_to('', class: ['btn btn-sm btn-danger cancel-invoice'], 'data-invoice-request-id': invoice_request.id, title: 'Cancel', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      end,
                      if is_authorized(invoice_request, 'index')
                        link_to('', class: ['btn btn-sm btn-success comment-invoice-request'], 'data-invoice-request-id': invoice_request.id, title: 'Add Comment', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-comment-lines'].join
                        end
                      end,
                  ].join(' '),
                  invoice_request.id,
                  status_badge(invoice_request.status),
                  conditional_link(invoice_request.inquiry.inquiry_number, edit_overseers_inquiry_path(invoice_request.inquiry), is_authorized(invoice_request.inquiry, 'edit')),
                  invoice_request.sales_order.present? ? conditional_link(invoice_request.sales_order.order_number, overseers_inquiry_sales_order_path(invoice_request.inquiry, invoice_request.sales_order), is_authorized(invoice_request.sales_order, 'show')) : '-',
                  (link_to(invoice_request.purchase_order.po_number, overseers_inquiry_purchase_order_path(invoice_request.inquiry, invoice_request.purchase_order), target: '_blank') if invoice_request.purchase_order.present?),
                  '<div class="text-center">' + invoice_request.inquiry.inside_sales_owner.to_s + '</div>',
                  invoice_request.purchase_order.logistics_owner.to_s,
                  format_succinct_date(invoice_request.created_at),
                  if invoice_request.last_comment.present?
                    format_succinct_date(invoice_request.last_comment.created_at)
                  end,
                  if invoice_request.last_comment.present?
                    format_comment(invoice_request.last_comment, trimmed: true)
                  end
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       Overseer.where(role: 'logistics').alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.reject { |h| h[:label] == 'Logistics Team'}.as_json,
                       [],
                       [],
                       []
                   ]

json.recordsTotal @invoice_requests.count
json.recordsFiltered @invoice_requests.total_count
json.draw params[:draw]
json.recordsSummary InvoiceRequest.statuses.map {|k, v| {status_id: v, "label": k, "size": @invoice_requests.pluck(:status).count(k)}}.as_json
