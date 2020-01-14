json.data (@inquiry_product_suppliers) do |inquiry_product_supplier|
  json.array! [
                  [
                      # if is_authorized(inquiry_product_suppliers ,'show')
                      #   row_action_button(overseers_inquiry_product_suppliers_path(inquiry_product_suppliers), 'eye', 'View Outward Dispatch', 'info', :_blank)
                      # end,
                      # if is_authorized(inquiry_product_suppliers,'edit')
                      #   row_action_button(edit_overseers_inquiry_product_suppliers_path(inquiry_product_suppliers), 'edit', 'Edit Outward Dispatch', 'warning', :_blank)
                      # end,
                      # if is_authorized(:inquiry_product_suppliers, 'can_create_packing_slip') && policy(inquiry_product_suppliers).can_create_packing_slip?
                      #   row_action_button(new_overseers_inquiry_product_suppliers_packing_slip_path(inquiry_product_suppliers), 'plus', 'Create Packing Slip', 'success', :_blank)
                      # end,
                      # if sales_invoice.present? && is_authorized(sales_invoice, 'can_send_pod_email') && policy(sales_invoice).create_email_message? && (inquiry_product_suppliers.status == 'Material Ready for Dispatch')
                      #   row_action_button(dispatch_mail_to_customer_overseers_sales_invoice_path(sales_invoice), 'envelope', 'Send Dispatch Mail', 'dark', :_blank)
                      # end,
                      # if sales_invoice.present? && is_authorized(sales_invoice, 'can_send_pod_email') && policy(sales_invoice).create_email_message? && (inquiry_product_suppliers.status == 'Material Delivered')
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
                      # if is_authorized(inquiry_product_suppliers, 'index')
                      #   link_to('', class: ['btn btn-sm btn-success comment-outward-dispatch'], 'data-model-id': inquiry_product_suppliers.id, title: 'Comment', remote: true) do
                      #     concat content_tag(:span, '')
                      #     concat content_tag :i, nil, class: ['fal fa-comment-lines'].join
                      #   end
                      # end,

                  ].join(' '),
                  link_to(@inquiry.inquiry_number, edit_overseers_inquiry_path(@inquiry), target: '_blank'),
                  inquiry_product_supplier.inquiry_product.to_s,
                  inquiry_product_supplier.supplier.to_s,
                  inquiry_product_supplier.inquiry_product.quantity,
                  inquiry_product_supplier.lead_time,
                  inquiry_product_supplier.unit_cost_price,
                  inquiry_product_supplier.final_unit_price,
                  inquiry_product_supplier.total_price,
                  inquiry_product_supplier.remarks,
                  # inquiry_product_supplier.packing_slips.map.with_index { |packing_slip,i| link_to("#{packing_slip.inquiry_product_supplier.ar_invoice_request.ar_invoice_number}-#{i + 1}", overseers_inquiry_product_supplier_packing_slip_path(inquiry_product_supplier, packing_slip), target: '_blank') }.compact.join(' '),
                  # link_to(ar_invoice_request.sales_order, overseers_inquiry_sales_order_path(ar_invoice_request.sales_order.inquiry, ar_invoice_request.sales_order), target: '_blank'),
                  # link_to((ar_invoice_request.ar_invoice_number || 'AR Invoice'), edit_overseers_ar_invoice_request_path(ar_invoice_request), target: '_blank'),
                  # inquiry_product_supplier.logistics_partner,
                  # inquiry_product_supplier.tracking_number,
                  # inquiry_product_supplier.status,
                  # format_boolean(inquiry_product_supplier.dispatch_mail_sent_to_the_customer),
                  # format_boolean(inquiry_product_supplier.material_delivered_mail_sent_to_customer),
                  # format_date(inquiry_product_supplier.material_dispatch_date),
                  # format_date(inquiry_product_supplier.expected_date_of_delivery),
                  # format_date(inquiry_product_supplier.material_delivery_date),
                  # inquiry_product_supplier.is_owner.present? ? inquiry_product_supplier.is_owner : '--',
                  # inquiry_product_supplier.logistics_owner.present? ? inquiry_product_supplier.logistics_owner : 'Unassigned',
                  format_date(inquiry_product_supplier.created_at),
              ]
end

# json.columnFilters [
#                        [],
#                        []
#                    ]

json.recordsTotal @inquiry_product_suppliers.count
json.recordsFiltered @inquiry_product_suppliers.count
json.draw params[:draw]
