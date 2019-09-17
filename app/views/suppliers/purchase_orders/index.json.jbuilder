json.data(@purchase_orders) do |purchase_order|
  json.array! [
                  [
                      row_action_button(suppliers_purchase_order_path(purchase_order), 'eye', 'View Purchase Order', 'info', :_blank),
                      row_action_button(suppliers_purchase_order_path(purchase_order, format: :pdf), 'file-pdf', 'Download Purchase Order', 'dark', :_blank)
                  ].join(' '),
                  purchase_order.po_number,
                  purchase_order.inquiry.inquiry_number,
                  (purchase_order.get_supplier(purchase_order.rows.first.metadata['PopProductId'].to_i).try(:name) if purchase_order.rows.present?),
                  purchase_order.status || purchase_order.metadata_status,
                  purchase_order.warehouse&.name,
                  purchase_order.rows.count,
                  format_succinct_date(purchase_order.po_date),
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

json.recordsTotal @purchase_orders.count
json.recordsFiltered @indexed_purchase_orders.total_count
json.draw params[:draw]
