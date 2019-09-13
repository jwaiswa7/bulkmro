json.data (@ar_invoice_requests) do |ar_invoice|
  json.array! [
                  [
                      if is_authorized(ar_invoice, 'show')
                        row_action_button(overseers_ar_invoice_request_path(ar_invoice), 'fal fa-fal fa-eye', 'View AR Invoice', 'info', :_blank)
                      end,
                      if is_authorized(ar_invoice, 'edit')
                        row_action_button(edit_overseers_ar_invoice_request_path(ar_invoice), 'pencil', 'Edit AR Invoice', 'warning', :_blank)
                      end,
                      if !ar_invoice.status.downcase.include?('cancel') && is_authorized(ar_invoice, 'can_cancel_or_reject')
                        link_to('', class: ['btn btn-sm btn-danger cancel-ar-invoice'], 'data-invoice-request-id': ar_invoice.id, title: 'Cancel', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      end,
                      if !ar_invoice.status.downcase.include?('reject') && is_authorized(ar_invoice, 'can_cancel_or_reject')
                        link_to('', class: ['btn btn-sm btn-warning reject-ar-invoice'], 'data-invoice-request-id': ar_invoice.id, title: 'Reject', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      end,
                      if is_authorized(ar_invoice, 'can_create_outward_dispatch') && ar_invoice.status == 'Completed AR Invoice Request' && policy(ar_invoice).can_create_outward_dispatch?
                        row_action_button(new_overseers_outward_dispatch_path(ar_invoice_request_id: ar_invoice), 'fal fa-plus', 'Add outward dispatch', 'info', :_blank)
                      end,
                      if is_authorized(ar_invoice, 'index') && policy(ar_invoice).index?
                        link_to('', class: ['btn btn-sm btn-success comment-ar-invoice-request'], 'data-model-id': ar_invoice.id, title: 'Comment', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-comment-lines'].join
                        end
                      end,
                  ].join(' '),
                  status_badge(ar_invoice.status),
                  ar_invoice.ar_invoice_number,
                  ar_invoice.inquiry.present? ? conditional_link(ar_invoice.inquiry.inquiry_number, edit_overseers_inquiry_path(ar_invoice.inquiry), is_authorized(ar_invoice.inquiry, 'edit')) : '-',
                  ar_invoice.inquiry.company.to_s,
                  ar_invoice.is_owner.present? ? ar_invoice.is_owner : '--',
                  ar_invoice.logistics_owner.present? ? ar_invoice.logistics_owner : 'Unassigned',
                  ar_invoice.sales_order.order_number,
                  ar_invoice.outward_dispatches.map { |outward_dispatch| link_to(outward_dispatch.id, overseers_outward_dispatch_path(outward_dispatch), target: '_blank') }.compact.join(' '),
                  format_succinct_date(ar_invoice.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       Overseer.inside.alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.as_json,
                       Overseer.where(role: 'logistics').alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.reject { |h| h[:label] == 'Logistics Team'}.as_json,
                       [],
                       [],
                       []
                   ]

json.recordsTotal @ar_invoice_requests.count
json.recordsFiltered @indexed_ar_invoices.total_count
json.draw params[:draw]
