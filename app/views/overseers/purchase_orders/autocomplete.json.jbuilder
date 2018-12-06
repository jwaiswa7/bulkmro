json.results(@purchase_orders) do |purchase_order|
  json.set! :id, purchase_order.id
  json.set! :text, purchase_order.po_number.to_s
end

json.pagination do
  json.set! :more, !@purchase_orders.last_page?
end