json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      row_action_button(customers_order_path(sales_order), 'arrow-right', 'Go to Inquiry', 'dark')
                  ].join(' '),
                  sales_order.inquiry.inquiry_number,
                  sales_order.inquiry.inside_sales_owner.to_s,
                  format_date(sales_order.created_at),
                  sales_order.inquiry.company.to_s,
                  sales_order.inquiry.outside_sales_owner.to_s,
                  sales_order.inquiry.customer_po_number,
                  sales_order.order_number,
                  sales_order_format_label(sales_order.status.to_s),
                  sales_order.remote_status.to_s,
                  format_currency(sales_order.calculated_total_margin),
              ]
end

json.recordsTotal @sales_orders.all.count
json.recordsFiltered @sales_orders.total_count
json.draw params[:draw]