json.data (@ar_invoice_requests) do |ar_invoice|
  sales_invoice = ar_invoice.sales_invoice
  json.array! [
                  [
                      if is_authorized(ar_invoice, 'show')
                        row_action_button_without_fa(overseers_ar_invoice_request_path(ar_invoice), 'bmro-icon-table bmro-icon-used-view', 'View AR Invoice', 'info', :_blank)
                      end,
                      if is_authorized(ar_invoice, 'edit')
                        row_action_button_without_fa(edit_overseers_ar_invoice_request_path(ar_invoice), 'bmro-icon-table bmro-icon-sighnature', 'Edit AR Invoice', 'warning', :_blank)
                      end,
                      if !ar_invoice.status.downcase.include?('cancel') && is_authorized(ar_invoice, 'can_cancel_or_reject')
                        link_to('', class: ['icon-title btn btn-sm btn-danger cancel-ar-invoice'], 'data-invoice-request-id': ar_invoice.id, title: 'Cancel', "data-status": 'Cancel', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['bmro-icon-table bmro-cancel-new-icon'].join
                        end
                      end,
                      if !ar_invoice.status.downcase.include?('reject') && is_authorized(ar_invoice, 'can_cancel_or_reject')
                        link_to('', class: ['icon-title btn btn-sm btn-warning reject-ar-invoice'], 'data-invoice-request-id': ar_invoice.id, title: 'Reject', "data-status": 'Reject', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['bmro-icon-table bmro-ban-new-icon'].join
                        end
                      end,
                      if sales_invoice.present? && is_authorized(sales_invoice, 'can_create_outward_dispatch') && policy(sales_invoice).can_create_outward_dispatch?
                        row_action_button_without_fa(new_overseers_outward_dispatch_path(sales_invoice_id: sales_invoice), 'bmro-icon-table bmro-relationship', 'Add outward dispatch', 'info', :_blank)
                      end,
                      if is_authorized(ar_invoice, 'index') && policy(ar_invoice).index?
                        link_to('', class: ['icon-title btn btn-sm btn-success comment-ar-invoice-request'], 'data-model-id': ar_invoice.id, title: 'Comment', 'data-title': 'Comment', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['bmro-icon-table bmro-icon-proof'].join
                        end
                      end,
                  ].join(' '),
                  status_badge(ar_invoice.status),
                  link_to(ar_invoice.ar_invoice_number, overseers_inquiry_sales_invoices_path(ar_invoice.inquiry),
                          target: '_blank'),
                  ar_invoice.inquiry.present? ? conditional_link(ar_invoice.inquiry.inquiry_number, edit_overseers_inquiry_path(ar_invoice.inquiry), is_authorized(ar_invoice.inquiry, 'edit')) : '-',
                  ar_invoice.inquiry.company.to_s,
                  ar_invoice.is_owner.present? ? ar_invoice.is_owner : '--',
                  ar_invoice.logistics_owner.present? ? ar_invoice.logistics_owner : 'Unassigned',
                  ar_invoice.sales_order.order_number,
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
                       []
                   ]

json.recordsTotal @ar_invoice_requests.count
json.recordsFiltered @indexed_ar_invoices.total_count
json.draw params[:draw]