json.data (@pending_sales_orders) do |pending_sales_order|
  json.array! [
                  [
                      if policy(pending_sales_order).comments?
                        row_action_button(overseers_inquiry_comments_path(pending_sales_order.inquiry, sales_order_id: pending_sales_order.to_param), 'comment-lines', pending_sales_order.inquiry.last_comment.message || 'See Comments', 'dark')
                      end,
                      if policy(pending_sales_order).go_to_inquiry?
                        row_action_button(overseers_inquiry_sales_orders_path(pending_sales_order.inquiry), 'arrow-right', 'Go to Inquiry', 'dark')
                      end
                  ].join(' '),
                  pending_sales_order.inquiry.inquiry_number,
                  pending_sales_order.inquiry.inside_sales_owner.to_s,
                  format_date(pending_sales_order.created_at),
                  pending_sales_order.inquiry.company.to_s,
                  pending_sales_order.inquiry.outside_sales_owner.to_s,
                  pending_sales_order.inquiry.customer_po_number,
                  format_currency(pending_sales_order.calculated_total),
                  format_currency(pending_sales_order.calculated_total_with_tax),
                  format_currency(pending_sales_order.calculated_total_margin),
              ]
end

json.recordsTotal @pending_sales_orders.model.all.count
json.recordsFiltered @pending_sales_orders.total_count
json.draw params[:draw]