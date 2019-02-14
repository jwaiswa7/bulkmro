json.results(@addresses) do |address|
  json.set! :id, address.id
  json.set! :text, address.to_s
end

json.pagination do
  json.set! :more, !@addresses.last_page?
end
