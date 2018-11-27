json.data (@customer_orders) do |customer_order|
  json.array! [

                  [
                      row_action_button(customers_customer_order_path(customer_order), 'comment-alt-check', 'View and Approve', 'success')
                  ].join(' '),
                  customer_order.id,
                  format_date(customer_order.created_at),
                  customer_order.contact.name,
              ]
end

json.recordsTotal @customer_orders.model.all.count
json.recordsFiltered @customer_orders.total_count
json.draw params[:draw]