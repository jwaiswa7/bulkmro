json.results(@brands) do |brand|
  json.set! :id, brand.id
  json.set! :text, brand.to_s
  json.set! :disabled, brand.is_active ? false : true
end

json.pagination do
  json.set! :more, !@brands.last_page?
end
