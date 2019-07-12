json.data (@sales_orders) do |sales_order|
  json.array! [
                  '',
                  sales_order.order_number,
                  format_succinct_date(sales_order.mis_date),
                  sales_order.inquiry_number,
                  sales_order.account_name,
                  sales_order.inside_sales_owner.to_s,
                  sales_order.inside_sales_owner.to_s,
                  format_currency(sales_order.order_total),
                  sales_order.order_total,
                  format_succinct_date(sales_order.created_at)
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
                       [],
                       []
                   ]


json.recordsTotal SalesOrder.all.count
json.recordsFiltered @sales_orders.total_count
json.draw params[:draw]
