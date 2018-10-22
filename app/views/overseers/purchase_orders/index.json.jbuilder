json.data (@purchase_orders) do |purchase_order|
  json.array! [
                  [
                      if policy(purchase_order).show?
                        row_action_button(overseers_purchase_orders_path(purchase_order.inquiry, purchase_order), 'eye', 'View Purchase Order', 'dark')
                      end,
                  ].join(' '),
                  purchase_order.po_number

              ]
end

json.recordsTotal @purchase_orders.model.all.count
json.recordsFiltered @purchase_orders.total_count
json.draw params[:draw]