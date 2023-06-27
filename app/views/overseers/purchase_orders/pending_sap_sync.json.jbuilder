json.data (@purchase_orders) do |purchase_order|
  json.array! [
                  [
                      row_action_button_without_fa(resync_po_overseers_purchase_order_path(purchase_order.to_param), 'bmro-icon-table fal fa-retweet-alt', 'Resync Purchase Order', 'danger'), 
                      row_action_button_without_fa(resync_urgent_po_overseers_purchase_order_path(purchase_order.to_param), 'bmro-icon-table bmro-icon-refresh', 'Resync Urgent', 'danger')
                  ],
                  purchase_order.inquiry.inquiry_number,
                  purchase_order.po_request.present? ? purchase_order.po_request.sales_order.present? ? link_to(purchase_order.po_request.sales_order.order_number, overseers_inquiry_sales_order_path(purchase_order.po_request.inquiry.to_param, purchase_order.po_request.sales_order.to_param)) : '-' : '-',
                  purchase_order.po_number,
                  purchase_order.rows.count,
                  purchase_order.inquiry.inside_sales_owner.to_s,
                  format_succinct_date(purchase_order.created_at)
              ]
end

json.recordsTotal @purchase_orders.count
json.recordsFiltered @purchase_orders.total_count
json.draw params[:draw]