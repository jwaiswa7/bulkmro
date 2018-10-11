json.data (@pending_sales_orders) do |pending_sales_order|
  json.array! [
                  [
                      if policy(pending_sales_order).comments?
                        row_action_button(overseers_inquiry_comments_path(pending_sales_order.inquiry, sales_order_id: pending_sales_order.to_param), 'comment-lines', 'See Comments', 'dark')
                      end,
                      if policy(pending_sales_order).go_to_inquiry?
                        row_action_button(overseers_inquiry_sales_orders_path(pending_sales_order.inquiry), 'arrow-right', 'Go to Inquiry', 'warning')
                      end,

                  ].join(' '),
                  pending_sales_order.created_by.to_s,
                  pending_sales_order.inquiry.to_s,
                  format_date(pending_sales_order.created_at),
              ]
end

json.recordsTotal @pending_sales_orders.model.all.count
json.recordsFiltered @pending_sales_orders.total_count
json.draw params[:draw]