json.data (@purchase_orders) do |purchase_order|
  json.array! [
                  [
                      row_action_button(resync_po_overseers_purchase_order_path(purchase_order.to_param), 'retweet-alt', 'Resync Purchase Order', 'danger')
                  ],
                  purchase_order.inquiry.inquiry_number,
                  purchase_order.rows.count,
                  purchase_order.inquiry.inside_sales_owner.to_s,
                  format_succinct_date(purchase_order.created_at)
              ]
end

json.recordsTotal @purchase_orders.count
json.recordsFiltered @purchase_orders.total_count
json.draw params[:draw]