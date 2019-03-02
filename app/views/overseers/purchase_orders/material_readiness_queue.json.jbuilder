json.data (@purchase_orders) do |purchase_order|
  json.array! [
                  [
                      if policy(purchase_order).update_logistics_owner?
                        "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='purchase_orders[]' class='custom-control-input' value='#{purchase_order.id}' id='c-#{purchase_order.id}'><label class='custom-control-label' for='c-#{purchase_order.id}'></label></div>"
                      end,
                      if policy(purchase_order).show?
                        row_action_button(overseers_inquiry_purchase_order_path(purchase_order.inquiry, purchase_order, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if policy(purchase_order).show_document?
                        row_action_button(url_for(purchase_order.document), 'file-pdf', purchase_order.document.filename, 'dark', :_blank)
                      end,
                      if policy(purchase_order).edit_material_followup?
                        row_action_button(edit_material_followup_overseers_purchase_order_path(purchase_order), 'list-alt', 'Edit Material Followup', 'success', :_blank)
                      end,
                      if policy(purchase_order).new_pickup_request?
                        row_action_button(new_overseers_purchase_order_material_pickup_request_path(purchase_order), 'plus-circle', 'Create Material Pickup Request', 'success', target: :_blank)
                      end,
                      if purchase_order.po_request.present? && policy(purchase_order.po_request).new_payment_request?
                        row_action_button(new_overseers_po_request_payment_request_path(purchase_order.po_request), 'dollar-sign', 'Payment Request', 'success', :_blank)
                      elsif purchase_order.po_request.present? && policy(purchase_order.po_request).show_payment_request?
                        row_action_button(overseers_payment_request_path(purchase_order.payment_request), 'eye', 'View Payment Request', 'success', :_blank)
                      end
                  ].join(' '),
                  link_to(purchase_order.inquiry.inquiry_number, edit_overseers_inquiry_path(purchase_order.inquiry), target: '_blank'),
                  purchase_order.inquiry.company.present? ? conditional_link(purchase_order.inquiry.company.try(:name), overseers_company_path(purchase_order.inquiry.company), policy(purchase_order.inquiry).show?) : '-',
                  (purchase_order.po_request.sales_order.order_number if purchase_order.po_request.present? && purchase_order.po_request.sales_order.present?),
                  (format_succinct_date(purchase_order.po_request.sales_order.mis_date) if purchase_order.po_request.present? && purchase_order.po_request.sales_order.present?),
                  (format_succinct_date(purchase_order.po_request.supplier_committed_date) if purchase_order.po_request.present?),
                  link_to(purchase_order.po_number, overseers_inquiry_purchase_orders_path(purchase_order.inquiry), target: '_blank'),
                  purchase_order.po_request.present? ? purchase_order.po_request.supplier_po_type : '',
                  format_succinct_date(purchase_order.metadata['PoDate'].try(:to_date)),
                  (purchase_order.supplier.present? ? conditional_link(purchase_order.supplier.try(:name), overseers_company_path(purchase_order.supplier), policy(purchase_order.inquiry).show?) : '-'),
                  purchase_order.po_request.buying_price,
                  purchase_order.po_request.selling_price,
                  purchase_order.po_request.po_margin_percentage,
                  (purchase_order.po_request.sales_order.calculated_total_margin_percentage if purchase_order.po_request.sales_order.present?),
                  purchase_order.inquiry.inside_sales_owner.to_s,
                  (purchase_order.logistics_owner.full_name if purchase_order.logistics_owner.present?),
                  status_badge(purchase_order.material_status),
                  format_succinct_date(purchase_order.followup_date),
                  format_succinct_date(purchase_order.revised_supplier_delivery_date),
                  (purchase_order.payment_request.present? ? status_badge(purchase_order.payment_request.status) : status_badge('Payment Request: Pending')),
                  (percentage(purchase_order.payment_request.percent_amount_paid, precision: 2) if purchase_order.payment_request.present?),
                  format_succinct_date(purchase_order.email_sent_to_supplier_date) ,
                  if purchase_order.last_comment.present?
                    format_comment(purchase_order.last_comment, trimmed: true)
                  end
              ]
end

json.columnFilters [
                       [],
                       [],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       [],
                       [],
                       [],
                       PoRequest.supplier_po_types.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       [],
                       [],
                       [],
                       Overseer.inside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       Overseer.where(role: 'logistics').alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       PurchaseOrder.material_statuses.except(:'Material Delivered').map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       [],
                       PaymentRequest.statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       []
                   ]

json.recordsTotal PurchaseOrder.all.count
json.recordsFiltered @indexed_purchase_orders.total_count
json.draw params[:draw]
