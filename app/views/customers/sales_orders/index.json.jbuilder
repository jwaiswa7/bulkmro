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
                  sales_order_status_badge(sales_order.status.to_s),
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
                       SalesOrder.statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json
                   ]

json.recordsTotal @sales_orders.count
json.recordsFiltered @indexed_sales_orders.total_count
json.draw params[:draw]