json.results(@companies) do |company|
  json.set! :id, company.id
  json.set! :text, company.to_s
end

json.pagination do
  json.set! :more, !@companies.last_page?
end