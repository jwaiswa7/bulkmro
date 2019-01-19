json.data (@material_pickup_requests) do |material_pickup_request|
  json.array! [
                  [

                      if policy(material_pickup_request).show?
                        row_action_button(overseers_purchase_order_material_pickup_request_path(material_pickup_request.purchase_order, material_pickup_request), 'eye', 'View Material Pickup Request', 'info', target: :_blank)
                      end,
                      if policy(material_pickup_request).edit?
                        row_action_button(edit_overseers_purchase_order_material_pickup_request_path(material_pickup_request.purchase_order, material_pickup_request), 'pencil', 'Edit Pickup Request', 'warning')
                      end,
                      if policy(material_pickup_request).confirm_delivery?
                        row_action_button(confirm_delivery_overseers_purchase_order_material_pickup_request_path(material_pickup_request.purchase_order, material_pickup_request), 'check', 'Confirm Delivery', 'success')
                      end,
                      if policy(material_pickup_request).delivered? && policy(material_pickup_request.purchase_order).can_request_invoice?
                        row_action_button(new_overseers_invoice_request_path(purchase_order_id: material_pickup_request.purchase_order, mpr_id: material_pickup_request), 'plus', 'Create Invoice Request', 'success', target: :_blank)
                      end,
                  ].join(' '),

                  link_to(material_pickup_request.purchase_order.po_number, overseers_inquiry_purchase_orders_path(material_pickup_request.purchase_order.inquiry), target: "_blank"),
                  link_to(material_pickup_request.purchase_order.inquiry.inquiry_number, edit_overseers_inquiry_path(material_pickup_request.purchase_order.inquiry), target: "_blank"),
                  (material_pickup_request.purchase_order.get_supplier(material_pickup_request.purchase_order.rows.first.metadata['PopProductId'].to_i).try(:name) if material_pickup_request.purchase_order.rows.present?),
                  (material_pickup_request.purchase_order.inquiry.company.try(:name) if material_pickup_request.purchase_order.inquiry.company.present?),
                  material_pickup_request.purchase_order.status || material_pickup_request.purchase_order.metadata_status,
                  material_pickup_request.purchase_order.inquiry.inside_sales_owner.to_s,
                  material_pickup_request.purchase_order.inquiry.outside_sales_owner.to_s,
                  format_date(material_pickup_request.purchase_order.created_at),
                  if material_pickup_request.purchase_order.last_comment.present?
                    format_date_time_meridiem(material_pickup_request.purchase_order.last_comment.updated_at)
                  end,
                  if material_pickup_request.purchase_order.last_comment.present?
                    format_comment(material_pickup_request.purchase_order.last_comment, trimmed: true)
                  end
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [{"source": autocomplete_overseers_companies_path}],
                       [{"source": autocomplete_overseers_companies_path}],
                       [],
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       [],
                       []
                   ]

json.recordsTotal @material_pickup_requests.model.count
json.recordsFiltered @material_pickup_requests.count
json.draw params[:draw]
