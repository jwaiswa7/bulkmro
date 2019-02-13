

json.results(@banks) do |bank|
  json.set! :id, bank.id
  json.set! :text, bank.to_s
end

json.pagination do
  json.set! :more, !@banks.last_page?
end
