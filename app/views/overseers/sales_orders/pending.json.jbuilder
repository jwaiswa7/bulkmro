json.data (@sales_orders) do |sales_order|
  json.array! [
                  format_date(sales_order.created_at),
                  sales_order.created_by.to_s,
                  sales_order.inquiry.to_s,
                  [
                      if policy(sales_order).comments?
                        row_action_button(overseers_inquiry_comments_path(sales_order.inquiry,  sales_order_id: sales_order.to_param), 'comment-lines', 'See Comments', 'success')
                      end,
                      if policy(sales_order).go_to_inquiry?
                        row_action_button(overseers_inquiry_sales_orders_path(sales_order.inquiry), 'arrow-right', 'Go to Inquiry', 'warning')
                      end,

                  ].join(' ')
              ]
end

json.recordsTotal @sales_orders.model.all.count
json.recordsFiltered @sales_orders.total_count
json.draw params[:draw]