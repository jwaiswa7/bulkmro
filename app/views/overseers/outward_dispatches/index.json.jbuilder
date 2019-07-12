json.data (@outward_dispatches) do |outward_dispatch|
  ar_invoice_request = outward_dispatch.ar_invoice_request
  sales_invoice = ar_invoice_request.sales_invoice
  json.array! [
                  [
                      if is_authorized(outward_dispatch ,'show')
                        row_action_button(overseers_outward_dispatch_path(outward_dispatch), 'eye', 'View Outward Dispatch', 'info', :_blank)
                      end,
                      if is_authorized(outward_dispatch,'edit')
                        row_action_button(edit_overseers_outward_dispatch_path(outward_dispatch), 'edit', 'Edit Outward Dispatch', 'warning', :_blank)
                      end,
                      if is_authorized(:outward_dispatch, 'can_create_packing_slip') && policy(outward_dispatch).can_create_packing_slip?
                        row_action_button(new_overseers_outward_dispatch_packing_slip_path(outward_dispatch), 'plus', 'Create Packing Slip', 'success', :_blank)
                      end,
                      if is_authorized(:outward_dispatch, 'can_send_dispatch_email') && current_overseer.can_send_emails?
                        row_action_button(dispatch_mail_to_customer_overseers_outward_dispatch_email_messages_path(outward_dispatch), 'envelope', 'Send Dispatch Mail', 'dark', :_blank)
                      end,
                      if is_authorized(sales_invoice, 'edit_pod') && policy(sales_invoice).edit_pod? && (sales_invoice.pod_rows.count == 0)
                        row_action_button(edit_pod_overseers_sales_invoice_path(sales_invoice), 'truck', 'Add Proof of Delivery', 'success')
                      end,
                      if is_authorized(sales_invoice, 'edit_pod') && policy(sales_invoice).edit_pod? && (sales_invoice.pod_rows.count > 0)
                        [
                            row_action_button(edit_pod_overseers_sales_invoice_path(sales_invoice), 'pencil', 'Edit Proof of Delivery', 'info'),
                        ]
                      end,
                  ].join(' '),
                  outward_dispatch.packing_slips.map.with_index { |packing_slip,i| link_to("#{packing_slip.outward_dispatch.ar_invoice_request.ar_invoice_number}-#{i + 1}", overseers_outward_dispatch_packing_slip_path(outward_dispatch, packing_slip), target: '_blank') }.compact.join(' '),
                  link_to(ar_invoice_request.inquiry.inquiry_number, edit_overseers_inquiry_path(ar_invoice_request.inquiry), target: '_blank'),
                  link_to(ar_invoice_request.sales_order, overseers_inquiry_sales_order_path(ar_invoice_request.sales_order.inquiry, ar_invoice_request.sales_order), target: '_blank'),
                  link_to(ar_invoice_request.ar_invoice_number, edit_overseers_ar_invoice_request_path(ar_invoice_request), target: '_blank'),
                  outward_dispatch.logistics_partner,
                  outward_dispatch.tracking_number,
                  outward_dispatch.status,
                  format_boolean(outward_dispatch.dispatch_mail_sent_to_the_customer),
                  format_boolean(outward_dispatch.material_delivered_mail_sent_to_customer),
                  format_date(outward_dispatch.material_dispatch_date),
                  format_date(outward_dispatch.expected_date_of_delivery),
                  format_date(outward_dispatch.material_delivery_date),
                  outward_dispatch.ar_invoice_request.inquiry.inside_sales_owner.to_s,
                  outward_dispatch.ar_invoice_request.inquiry.company.logistics_owner.present? ? outward_dispatch.ar_invoice_request.inquiry.company.logistics_owner.full_name : 'Unassigned',
                  format_date(outward_dispatch.created_at),
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
                       OutwardDispatch.statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @indexed_outward_dispatches.count
json.recordsFiltered @indexed_outward_dispatches.total_count
json.draw params[:draw]
