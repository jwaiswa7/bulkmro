json.data (@sales_shipments) do |sales_shipment|
  json.array! [
                  [
                      if is_authorized(sales_shipment, 'relationship_map')
                        row_action_button_without_fa(relationship_map_overseers_inquiry_sales_shipment_path(sales_shipment.inquiry.to_param, sales_shipment.to_param), 'bmro-icon-table bmro-icon-relationship', 'Relationship Map', 'info', :_blank)
                      end,
                      if is_authorized(sales_shipment, 'show') && policy(sales_shipment).show?
                        row_action_button_without_fa(overseers_inquiry_sales_shipment_path(sales_shipment.inquiry, sales_shipment, format: :pdf), 'bmro-icon-table bmro-icon-pdf', 'Download', 'dark', :_blank)
                      end,
                      if is_authorized(sales_shipment, 'show_shipment_pdf') && policy(sales_shipment).show_shipment_pdf?
                        row_action_button_without_fa(url_for(sales_shipment.shipment_pdf), 'bmro-icon-table bmro-icon-pdf', sales_shipment.shipment_pdf.filename, 'dark', :_blank)
                      end,
                  ].join(' '),
                  conditional_link(sales_shipment.shipment_number, overseers_inquiry_sales_shipments_path(sales_shipment.inquiry, sales_shipment), is_authorized(sales_shipment, 'show') && policy(sales_shipment).show?),
                  conditional_link(sales_shipment.inquiry.inquiry_number, edit_overseers_inquiry_path(sales_shipment.inquiry), is_authorized(sales_shipment.inquiry, 'edit') && policy(sales_shipment.inquiry).edit?),
                  conditional_link(sales_shipment.sales_order.order_number, overseers_inquiry_sales_order_path(sales_shipment.inquiry, sales_shipment.sales_order), is_authorized(sales_shipment.sales_order, 'show') && policy(sales_shipment.sales_order).show?),
                  sales_shipment.rows.count,
                  sales_shipment.status,
                  sales_shipment.inquiry.inside_sales_owner.to_s,
                  sales_shipment.inquiry.outside_sales_owner.to_s,
                  format_succinct_date(sales_shipment.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       SalesShipment.statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       Overseer.inside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       Overseer.outside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       []
                   ]

json.recordsTotal SalesShipment.all.count
json.recordsFiltered @indexed_sales_shipments.total_count
json.draw params[:draw]
json.status @statuses
json.recordsSummary SalesShipment.statuses.map { |status, status_id| { status_id: status_id, "label": status, "size": @statuses[status_id] } }.as_json
