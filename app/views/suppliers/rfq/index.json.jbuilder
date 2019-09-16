json.data(@rfqs) do |rfq|
  json.array! [
                  [
                      row_action_button(suppliers_rfq_path(rfq), 'eye', 'View RFQ', 'info', :_blank),
                      row_action_button(edit_suppliers_rfq_path(rfq), 'pencil', 'Edit RFQ', 'info', :_blank)
                  ].join(' '),
                  rfq.inquiry_product.product.to_s,

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
                       []
                   ]

json.recordsTotal @rfqs.count
json.recordsFiltered @indexed_rfqs.total_count
json.draw params[:draw]
