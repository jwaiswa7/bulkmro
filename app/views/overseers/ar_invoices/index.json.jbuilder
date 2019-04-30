json.data (@ar_invoices) do |ar_invoice|
  json.array! [
                  [
                      if true
                        row_action_button(overseers_ar_invoice_path(ar_invoice),'fal fa-eye', 'View AR Invoice', 'info', :_blank)
                      end,
                      if true
                        row_action_button(edit_overseers_ar_invoice_path(ar_invoice),'pencil', 'Edit AR Invoice', 'warning', :_blank)
                      end,
                      if !ar_invoice.status.downcase.include?('cancel') && policy(ar_invoice).can_cancel_or_reject?
                        link_to('', class: ['btn btn-sm btn-danger cancel-ar-invoice'], 'data-invoice-request-id': ar_invoice.id, title: 'Cancel', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      end,
                      if !ar_invoice.status.downcase.include?('reject') && policy(ar_invoice).can_cancel_or_reject?
                        link_to('', class: ['btn btn-sm btn-warning reject-ar-invoice'], 'data-invoice-request-id': ar_invoice.id, title: 'Reject', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      end
                        ].join(' '),
                  status_badge(ar_invoice.status),
                  ar_invoice.id,
                  ar_invoice.inquiry.inquiry_number,
                  ar_invoice.sales_order.order_number
              ]
end
json.recordsTotal ArInvoice.all.count
json.recordsFiltered @indexed_ar_invoices.total_count
json.draw params[:draw]
