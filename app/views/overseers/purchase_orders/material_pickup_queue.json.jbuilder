json.data (@material_pickup_requests) do |material_pickup_request|
  json.array! [
                  [
                      if (policy(material_pickup_request).update_logistics_owner_for_pickup_requests? && (material_pickup_request.status != 'Material Delivered'));
                        "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='the_pickup_requests[]' class='custom-control-input' value='#{material_pickup_request.id}' id='c-#{material_pickup_request.id}'><label class='custom-control-label' for='c-#{material_pickup_request.id}'></label></div>"
                      end,
                      if policy(material_pickup_request).delivered? && policy(material_pickup_request).can_request_invoice?
                        "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='pickup_requests[]' class='custom-control-input' value='#{material_pickup_request.id}' id='c-#{material_pickup_request.id}' data-po-id='#{material_pickup_request.purchase_order.id}'><label class='custom-control-label' for='c-#{material_pickup_request.id}'></label></div>"
                      end,
                      if policy(material_pickup_request).show?
                        row_action_button(overseers_purchase_order_material_pickup_request_path(material_pickup_request.purchase_order, material_pickup_request), 'eye', 'View Material Pickup Request', 'info', target: :_blank)
                      end,
                      if policy(material_pickup_request).edit?
                        row_action_button(edit_overseers_purchase_order_material_pickup_request_path(material_pickup_request.purchase_order, material_pickup_request), 'pencil', 'Edit Pickup Request', 'warning')
                      end,
                      if policy(material_pickup_request).confirm_delivery?
                        row_action_button(confirm_delivery_overseers_purchase_order_material_pickup_request_path(material_pickup_request.purchase_order, material_pickup_request), 'check', 'Confirm Delivery', 'success')
                      end,
                      if policy(material_pickup_request).delivered? && policy(material_pickup_request).can_request_invoice?
                        row_action_button(new_overseers_invoice_request_path(purchase_order_id: material_pickup_request.purchase_order, mpr_id: material_pickup_request), 'plus', 'Create Invoice Request', 'success', target: :_blank)
                      elsif material_pickup_request.invoice_request.present? && policy(material_pickup_request.invoice_request).show?
                        row_action_button(overseers_invoice_request_path(material_pickup_request.invoice_request), 'eye', "View #{material_pickup_request.invoice_request.readable_status}", 'success', target: :_blank)
                      end,
                  ].join(' '),
                  link_to(material_pickup_request.purchase_order.inquiry.inquiry_number, edit_overseers_inquiry_path(material_pickup_request.purchase_order.inquiry), target: '_blank'),
                  (material_pickup_request.purchase_order.inquiry.company.try(:name) if material_pickup_request.purchase_order.inquiry.company.present?),
                  (material_pickup_request.purchase_order.po_request.sales_order.order_number if material_pickup_request.purchase_order.po_request.present? && material_pickup_request.purchase_order.po_request.sales_order.present?),
                  (material_pickup_request.purchase_order.po_request.sales_order.mis_date if material_pickup_request.purchase_order.po_request.present? && material_pickup_request.purchase_order.po_request.sales_order.present?),
                  (material_pickup_request.purchase_order.po_request.supplier_committed_date if material_pickup_request.purchase_order.po_request.present?),
                  link_to(material_pickup_request.purchase_order.po_number, overseers_inquiry_purchase_orders_path(material_pickup_request.purchase_order.inquiry), target: '_blank'),
                  material_pickup_request.purchase_order.metadata['PoDate'],
                  (material_pickup_request.purchase_order.get_supplier(material_pickup_request.purchase_order.rows.first.metadata['PopProductId'].to_i).try(:name) if material_pickup_request.purchase_order.rows.present?),
                  material_pickup_request.purchase_order.inquiry.inside_sales_owner.to_s,
                  (material_pickup_request.logistics_owner.full_name if material_pickup_request.logistics_owner.present?),
                  material_pickup_request.purchase_order.status || material_pickup_request.purchase_order.metadata_status,
                  (material_pickup_request.purchase_order.po_request.status if material_pickup_request.purchase_order.po_request.present?),
                  (material_pickup_request.purchase_order.payment_request.status if material_pickup_request.purchase_order.payment_request.present?),
                  material_pickup_request.purchase_order.material_status,
                  if material_pickup_request.last_comment.present?
                    format_comment(material_pickup_request.last_comment, trimmed: true)
                  end,
                  format_date(material_pickup_request.expected_dispatch_date),
                  material_pickup_request.logistics_partner,
                  material_pickup_request.tracking_number,
                  format_date(material_pickup_request.expected_delivery_date)
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
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       Overseer.logistics.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
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

json.recordsTotal MaterialPickupRequest.count
json.recordsFiltered @material_pickup_requests.count
json.draw params[:draw]
