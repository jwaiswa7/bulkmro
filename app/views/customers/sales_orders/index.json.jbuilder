json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      row_action_button(customers_order_path(sales_order), 'eye', 'View Order', 'info'),
                      row_action_button(customers_order_path(sales_order, format: :pdf), 'file-pdf', 'Download Order', 'dark', :_blank)
                  ].join(' '),
                  sales_order.order_number,
                  sales_order.inquiry.inquiry_number,
                  format_date(sales_order.created_at),
                  sales_order.inquiry.customer_po_number,
                  sales_order.inquiry.company.to_s,
                  "-",
                  format_currency(sales_order.calculated_total),
                  sales_order_customer_status_badge(sales_order.customer_status.to_s),
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [{"label"=>"Delivered", "value"=>"Delivered"},{"label"=>"Not delivered", "value"=>"Not delivered"}]
                   ]

json.recordsTotal @sales_orders.count
json.recordsFiltered @indexed_sales_orders.total_count
json.draw params[:draw]