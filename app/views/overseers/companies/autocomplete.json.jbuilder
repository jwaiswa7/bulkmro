json.results(@companies) do |company|
  json.set! :id, company.id
  json.set! :text, company.to_s_with_type
end

json.pagination do
  json.set! :more, !@companies.last_page?
end
