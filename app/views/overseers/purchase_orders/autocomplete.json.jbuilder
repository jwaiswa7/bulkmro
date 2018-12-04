json.results(@purchase_orders) do |purchase_order|
  json.set! :id, purchase_order.id
  json.set! :text, purchase_order.to_s
end

json.pagination do
  json.set! :more, !@indexed_purchase_orders.last_page?
end