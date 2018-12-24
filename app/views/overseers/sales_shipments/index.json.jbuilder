json.data (@sales_shipments) do |sales_shipment|
  json.array! [
                  [
                      if policy(sales_shipment).show?
                        row_action_button(overseers_inquiry_sales_shipment_path(sales_shipment.inquiry, sales_shipment, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if policy(sales_shipment).show_shipment_pdf?
                        row_action_button(url_for(sales_shipment.shipment_pdf), 'file-pdf', sales_shipment.shipment_pdf.filename, 'dark', :_blank)
                      end,
                  ].join(' '),
                  sales_shipment.shipment_number,
                  link_to(sales_shipment.inquiry.inquiry_number, edit_overseers_inquiry_path(sales_shipment.inquiry), target: '_blank'),
                  link_to(sales_shipment.sales_order.order_number, overseers_inquiry_sales_order_path(sales_shipment.inquiry, sales_shipment.sales_order), target: "_blank"),
                  sales_shipment.rows.count,
                  sales_shipment.status,
                  sales_shipment.inquiry.inside_sales_owner.to_s,
                  sales_shipment.inquiry.outside_sales_owner.to_s,
                  format_date(sales_shipment.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       SalesShipment.statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       []
                   ]

json.recordsTotal SalesShipment.all.count
json.recordsFiltered @indexed_sales_shipments.total_count
json.draw params[:draw]