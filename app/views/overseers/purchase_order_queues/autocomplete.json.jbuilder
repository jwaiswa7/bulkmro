json.results(@purchase_order_queues) do |kit|
  json.set! :id, kit.id
  json.set! :text, kit.to_s
end

json.pagination do
  json.set! :more, !@purchase_order_queues.last_page?
end