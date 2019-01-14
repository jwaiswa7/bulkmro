json.results(@warehouse) do |warehouse|
  json.set! :id, warehouse.id
  json.set! :text, warehouse.to_s
end

json.pagination do
  json.set! :more, !@warehouse.last_page?
end