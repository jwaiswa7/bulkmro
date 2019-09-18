json.data(@rfqs) do |rfq|
  json.array! [
                  [
                      row_action_button(edit_suppliers_rfq_path(rfq), 'pencil', 'Edit RFQ', 'warning', :_blank),
                      row_action_button(suppliers_rfq_path(rfq), 'eye', 'View RFQ', 'info', :_blank)
                  ].join(' '),
                  rfq.inquiry_product_supplier.product.to_s,
                  rfq.inquiry_product_supplier.product.mpn,
                  rfq.inquiry_product_supplier.product.brand.name,
                  rfq.inquiry_product_supplier.inquiry_product.quantity,
                  rfq.inquiry_product_supplier.lead_time,
                  rfq.inquiry_product_supplier.last_unit_price,
                  rfq.inquiry_product_supplier.gst,
                  rfq.inquiry_product_supplier.final_unit_price,
                  rfq.inquiry_product_supplier.total_price
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
                       [],
                       [],
                       []
                   ]

json.recordsTotal @rfqs.count
json.recordsFiltered @rfqs.count
json.draw params[:draw]
