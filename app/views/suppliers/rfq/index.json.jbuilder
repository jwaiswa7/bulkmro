json.data(@product_suppliers) do |inquiry_product_supplier|
  json.array! [
                  [
                      row_action_button(edit_suppliers_rfq_path(inquiry_product_supplier), 'pencil', 'Edit RFQ', 'warning', :_blank),
                      row_action_button(suppliers_rfq_path(inquiry_product_supplier), 'eye', 'View RFQ', 'info', :_blank)
                  ].join(' '),
                  inquiry_product_supplier.product.to_s,
                  inquiry_product_supplier.product.mpn,
                  inquiry_product_supplier.product.brand.name,
                  inquiry_product_supplier.inquiry_product.quantity,
                  inquiry_product_supplier.lead_time,
                  inquiry_product_supplier.last_unit_price,
                  inquiry_product_supplier.gst,
                  inquiry_product_supplier.final_unit_price,
                  inquiry_product_supplier.total_price
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

json.recordsTotal @product_suppliers.count
json.recordsFiltered @product_suppliers.count
json.draw params[:draw]
