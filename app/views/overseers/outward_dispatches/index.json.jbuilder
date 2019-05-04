json.data (@outward_dispatches) do |outward_dispatch|
  ar_invoice_request = outward_dispatch.ar_invoice_request
  json.array! [
                  [
                      if policy(outward_dispatch).show?
                        row_action_button(overseers_outward_dispatch_path(outward_dispatch), 'eye', 'View Outward Dispatch', 'info', :_blank)
                      end,
                      if policy(outward_dispatch).edit?
                        row_action_button(edit_overseers_outward_dispatch_path(outward_dispatch), 'pencil', 'Edit Outward Dispatch', 'warning', :_blank)
                      end,
                      if policy(outward_dispatch).can_create_packing_slip?
                        row_action_button(new_overseers_outward_dispatch_packing_slip_path(outward_dispatch), 'plus', 'Create Packing Slip', 'success', :_blank)
                      end
                  ].join(' '),
                  outward_dispatch.id,
                  link_to(ar_invoice_request.inquiry.inquiry_number, edit_overseers_inquiry_path(ar_invoice_request.inquiry), target: '_blank'),
                  link_to(ar_invoice_request.sales_order, edit_overseers_sales_order_path(ar_invoice_request.sales_order), target: '_blank'),
                  link_to(ar_invoice_request.id, edit_overseers_ar_invoice_request_path(ar_invoice_request), target: '_blank'),
                  format_date(outward_dispatch.created_at),
              ]
end

json.recordsTotal @indexed_outward_dispatches.count
json.recordsFiltered @indexed_outward_dispatches.total_count
json.draw params[:draw]
