json.data (@purchase_orders) do |purchase_order|
  json.array! [
                  [
                      if is_authorized(purchase_order, 'update_logistics_owner')
                        "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='purchase_orders[]' class='custom-control-input' value='#{purchase_order.id}' id='c-#{purchase_order.id}'><label class='custom-control-label' for='c-#{purchase_order.id}'></label></div>"
                      end,
                      if is_authorized(purchase_order, 'show')
                        row_action_button(overseers_inquiry_purchase_order_path(purchase_order.inquiry, purchase_order, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if is_authorized(purchase_order, 'show_document')
                        row_action_button(url_for(purchase_order.document), 'file-pdf', purchase_order.document.filename, 'dark', :_blank)
                      end,
                      if is_authorized(purchase_order, 'edit_material_followup')
                        row_action_button(edit_material_followup_overseers_purchase_order_path(purchase_order), 'list-alt', 'Edit Material Followup', 'success', :_blank)
                      end,
                      if is_authorized(purchase_order, 'new_inward_dispatch') && is_authorized(purchase_order, 'edit_material_followup')
                        row_action_button(new_overseers_purchase_order_inward_dispatch_path(purchase_order), 'people-carry', 'Create Inward Dispatch', 'success', target: :_blank)
                      end,
                      if purchase_order.po_request.present? && is_authorized(purchase_order.po_request, 'new_payment_request')
                        row_action_button(new_overseers_po_request_payment_request_path(purchase_order.po_request), 'dollar-sign', 'Payment Request', 'success', :_blank)
                      elsif purchase_order.po_request.present? && is_authorized(purchase_order.po_request, 'show_payment_request')
                        row_action_button(overseers_payment_request_path(purchase_order.po_request.payment_request), 'eye', 'View Payment Request', 'success', :_blank)
                      end,
                      if purchase_order.po_request.present? && is_authorized(purchase_order.po_request, 'dispatch_supplier_delayed_new_email_message') && current_overseer.smtp_password.present?
                        row_action_button(dispatch_from_supplier_delayed_overseers_po_request_email_messages_path(purchase_order.po_request), 'envelope', 'Dispatch from Supplier Delayed', 'success', :_blank)
                      end
                  ].join(' '),
                  purchase_order.po_request.present? ? (conditional_link(purchase_order.po_request.id, overseers_po_request_path(purchase_order.po_request), is_authorized(purchase_order.po_request, 'show'))) : '-',
                  link_to(purchase_order.inquiry.inquiry_number, edit_overseers_inquiry_path(purchase_order.inquiry), target: '_blank'),
                  purchase_order.inquiry.company.present? ? conditional_link(purchase_order.inquiry.company.try(:name), overseers_company_path(purchase_order.inquiry.company), is_authorized(purchase_order.inquiry, 'show')) : '-',
                  status_badge(purchase_order.material_status),
                  link_to(purchase_order.po_number, overseers_inquiry_purchase_orders_path(purchase_order.inquiry), target: '_blank'),
                  (purchase_order.po_date ? format_succinct_date(purchase_order.po_date) : '-'),
                  (purchase_order.supplier.present? ? conditional_link(purchase_order.supplier.try(:name), overseers_company_path(purchase_order.supplier), is_authorized(purchase_order.inquiry, 'show')) : '-'),
                  purchase_order.po_request.present? ? purchase_order.po_request.supplier_po_type : '',
                  (format_comment(purchase_order.last_comment, trimmed: true) if purchase_order.last_comment.present?),
                  (format_succinct_date(purchase_order.po_request.sales_order.mis_date) if purchase_order.po_request.present? && purchase_order.po_request.sales_order.present?),
                  (purchase_order.po_request.sales_order.order_number if purchase_order.po_request.present? && purchase_order.po_request.sales_order.present?),
                  (format_succinct_date(purchase_order.po_request.inquiry.customer_committed_date) if purchase_order.po_request.present?),
                  purchase_order.inquiry.inside_sales_owner.to_s,
                  (purchase_order.logistics_owner.present? ? purchase_order.logistics_owner.full_name : 'Unassigned'),
                  format_succinct_date(purchase_order.followup_date),
                  format_succinct_date(purchase_order.revised_supplier_delivery_date),
                  (purchase_order.payment_request.present? ? status_badge(purchase_order.payment_request.status) : status_badge('Payment Request: Pending')),
                  (percentage(purchase_order.payment_request.percent_amount_paid, precision: 2) if purchase_order.payment_request.present?),
                  format_succinct_date(purchase_order.email_sent_to_supplier_date),
                  (purchase_order.po_request.buying_price if purchase_order.po_request.present?),
                  (purchase_order.po_request.selling_price if purchase_order.po_request.present?),
                  (purchase_order.po_request.po_margin_percentage if purchase_order.po_request.present?),
                  (purchase_order.po_request.sales_order.calculated_total_margin_percentage if purchase_order.po_request.present? && purchase_order.po_request.sales_order.present?)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [{"source": autocomplete_overseers_companies_path}],
                       PurchaseOrder.material_statuses.except(:'Material Delivered').map {|k, v| {"label": k, "value": v.to_s}}.as_json,
                       [],
                       [],
                       [{"source": autocomplete_overseers_companies_path}],
                       PoRequest.supplier_po_types.map {|k, v| {"label": k, "value": v.to_s}}.as_json,
                       [],
                       [],
                       [],
                       [],
                       Overseer.inside.alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.as_json,
                       Overseer.where(role: 'logistics').alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.unshift(label: 'Unassigned', value: 0).as_json,
                       [],
                       [],
                       PaymentRequest.statuses.map {|k, v| {"label": k, "value": v.to_s}}.as_json,
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @indexed_purchase_orders.count
json.recordsFiltered @indexed_purchase_orders.total_count
json.draw params[:draw]
