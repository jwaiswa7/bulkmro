json.results(@customer_pos) do |customer_po|
  json.set! :id, customer_po.to_s
  json.set! :text, customer_po.to_s
end

json.pagination do
  json.set! :more, true
end
