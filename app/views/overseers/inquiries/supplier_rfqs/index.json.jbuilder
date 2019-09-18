json.data (@supplier_rfqs) do |supplier_rfq|
  json.array! [
                  [
                      # if is_authorized(supplier_rfq ,'show')
                      #   row_action_button(overseers_supplier_rfq_path(supplier_rfq), 'eye', 'View Outward Dispatch', 'info', :_blank)
                      # end,
                      # if is_authorized(supplier_rfq,'edit')
                      #   row_action_button(edit_overseers_supplier_rfq_path(supplier_rfq), 'edit', 'Edit Outward Dispatch', 'warning', :_blank)
                      # end,
                      # if is_authorized(:supplier_rfq, 'can_create_packing_slip') && policy(supplier_rfq).can_create_packing_slip?
                      #   row_action_button(new_overseers_supplier_rfq_packing_slip_path(supplier_rfq), 'plus', 'Create Packing Slip', 'success', :_blank)
                      # end,
                      # if sales_invoice.present? && is_authorized(sales_invoice, 'can_send_pod_email') && policy(sales_invoice).create_email_message? && (supplier_rfq.status == 'Material Ready for Dispatch')
                      #   row_action_button(dispatch_mail_to_customer_overseers_sales_invoice_path(sales_invoice), 'envelope', 'Send Dispatch Mail', 'dark', :_blank)
                      # end,
                      # if sales_invoice.present? && is_authorized(sales_invoice, 'can_send_pod_email') && policy(sales_invoice).create_email_message? && (supplier_rfq.status == 'Material Delivered')
                      #   row_action_button(delivery_mail_to_customer_overseers_sales_invoice_path(sales_invoice), 'envelope', 'Delivery Email', 'success')
                      # end,
                      # if sales_invoice.present? && is_authorized(sales_invoice, 'edit_pod') && policy(sales_invoice).edit_pod? && (sales_invoice.pod_rows.count == 0)
                      #   row_action_button(edit_pod_overseers_sales_invoice_path(sales_invoice), 'truck', 'Add Proof of Delivery', 'success')
                      # end,
                      # if sales_invoice.present? && is_authorized(sales_invoice, 'edit_pod') && policy(sales_invoice).edit_pod? && (sales_invoice.pod_rows.count > 0)
                      #   [
                      #       row_action_button(edit_pod_overseers_sales_invoice_path(sales_invoice), 'pencil', 'Edit Proof of Delivery', 'info'),
                      #   ]
                      # end,
                      # if is_authorized(supplier_rfq, 'index')
                      #   link_to('', class: ['btn btn-sm btn-success comment-outward-dispatch'], 'data-model-id': supplier_rfq.id, title: 'Comment', remote: true) do
                      #     concat content_tag(:span, '')
                      #     concat content_tag :i, nil, class: ['fal fa-comment-lines'].join
                      #   end
                      # end,

                  ].join(' '),
                  link_to(@inquiry.inquiry_number, edit_overseers_inquiry_path(@inquiry), target: '_blank'),

                  # supplier_rfq.packing_slips.map.with_index { |packing_slip,i| link_to("#{packing_slip.supplier_rfq.ar_invoice_request.ar_invoice_number}-#{i + 1}", overseers_supplier_rfq_packing_slip_path(supplier_rfq, packing_slip), target: '_blank') }.compact.join(' '),
                  # link_to(ar_invoice_request.sales_order, overseers_inquiry_sales_order_path(ar_invoice_request.sales_order.inquiry, ar_invoice_request.sales_order), target: '_blank'),
                  # link_to((ar_invoice_request.ar_invoice_number || 'AR Invoice'), edit_overseers_ar_invoice_request_path(ar_invoice_request), target: '_blank'),
                  # supplier_rfq.logistics_partner,
                  # supplier_rfq.tracking_number,
                  # supplier_rfq.status,
                  # format_boolean(supplier_rfq.dispatch_mail_sent_to_the_customer),
                  # format_boolean(supplier_rfq.material_delivered_mail_sent_to_customer),
                  # format_date(supplier_rfq.material_dispatch_date),
                  # format_date(supplier_rfq.expected_date_of_delivery),
                  # format_date(supplier_rfq.material_delivery_date),
                  # supplier_rfq.is_owner.present? ? supplier_rfq.is_owner : '--',
                  # supplier_rfq.logistics_owner.present? ? supplier_rfq.logistics_owner : 'Unassigned',
                  format_date(supplier_rfq.created_at),
              ]
end

# json.columnFilters [
#                        [],
#                        []
#                    ]

json.recordsTotal @supplier_rfqs.count
json.recordsFiltered @supplier_rfqs.count
json.draw params[:draw]
