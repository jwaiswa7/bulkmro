

json.results(@sales_orders) do |sales_order|
  json.set! :id, sales_order.id
  json.set! :text, sales_order.to_s
end
