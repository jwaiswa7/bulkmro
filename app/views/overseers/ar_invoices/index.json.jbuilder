json.data (@ar_invoices) do |ar_invoice|
  json.array! [
                  [
                      if true
                        row_action_button(overseers_ar_invoice_path(ar_invoice),'fal fa-eye', 'View AR Invoice', 'info', :_blank)
                      end,
                      if true
                        row_action_button(edit_overseers_ar_invoice_path(ar_invoice),'pencil', 'Edit AR Invoice', 'warning', :_blank)
                      end,
                      if true
                        row_action_button(overseers_ar_invoice_path(ar_invoice), 'fa fa-minus-circle', 'Destroy AR Invoice', 'danger', '',:destroy,  { confirm: 'Are you sure?' })
                      end

                  ].join(' '),
                  status_badge(ar_invoice.status),
                  ar_invoice.id,
                  ar_invoice.inquiry.inquiry_number,
                  ar_invoice.sales_order.order_number
              ]
end
