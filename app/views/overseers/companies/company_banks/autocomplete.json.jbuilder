json.results(@company_banks) do |bank|
  json.set! :id, bank.id
  json.set! :text, bank.to_s
end

json.pagination do
  json.set! :more, !@company_banks.last_page?
end