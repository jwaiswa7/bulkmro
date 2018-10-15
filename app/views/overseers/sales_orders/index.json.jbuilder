json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      if policy(sales_order).comments?
                        row_action_button(overseers_inquiry_comments_path(sales_order.inquiry, sales_order_id: sales_order.to_param), 'comment-lines', 'See Comments', 'dark')
                      end,
                      if policy(sales_order).go_to_inquiry?
                        row_action_button(overseers_inquiry_sales_orders_path(sales_order.inquiry), 'arrow-right', 'Go to Inquiry', 'dark')
                      end
                  ].join(' '),
                  sales_order.inquiry.inquiry_number,
                  sales_order.inquiry.inside_sales_owner.to_s,
                  format_date(sales_order.created_at),
                  sales_order.status.to_s.capitalize,
                  sales_order.remote_status.to_s,
                  sales_order.order_number,
                  sales_order.inquiry.company.to_s,
                  sales_order.inquiry.outside_sales_owner.to_s,
                  sales_order.inquiry.contact.to_s,
                  sales_order.inquiry.customer_po_number,
                  format_currency(sales_order.calculated_total),
                  format_currency(sales_order.calculated_total_with_tax),
                  format_currency(sales_order.calculated_total_margin),
              ]
end

json.recordsTotal @sales_orders.model.all.count
json.recordsFiltered @sales_orders.total_count
json.draw params[:draw]