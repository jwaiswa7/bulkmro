

json.results(@brands) do |brand|
  json.set! :id, brand.id
  json.set! :text, brand.to_s
end

json.pagination do
  json.set! :more, !@brands.last_page?
end
