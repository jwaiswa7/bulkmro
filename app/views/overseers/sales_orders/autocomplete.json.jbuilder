json.results(@sales_orders) do |sales_order|
  json.set! :id, sales_order.id
  json.set! :text, sales_order.to_s
end

json.pagination do
  json.set! :more, !@indexed_sales_orders.last_page?
end
