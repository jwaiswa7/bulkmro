json.results(@freight_quotes) do |freight_quote|
  json.set! :id, freight_quote.id
  json.set! :text, freight_quote.to_s
end

json.pagination do
  json.set! :more, !@freight_quotes.last_page?
end