json.data (@sales_orders) do |sales_order|
  json.array! [
                 [
                     row_action_button(new_accounts_confirmation_overseers_inquiry_sales_order_path(sales_order.inquiry.to_param, sales_order.to_param), 'comment-alt-check', 'Account Approval', 'warning')
                 ],
                 sales_order.inquiry.inquiry_number,
                 sales_order.rows.count,
                 sales_order.calculated_total_margin_percentage,
                 sales_order.inside_sales_owner.to_s,
                 format_succinct_date(sales_order.created_at)
              ]
end

json.recordsTotal @sales_orders.count
json.recordsFiltered @sales_orders.total_count
json.draw params[:draw]