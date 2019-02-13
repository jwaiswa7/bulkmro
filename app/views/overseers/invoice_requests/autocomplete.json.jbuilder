

json.results(@invoice_requests) do |invoice_request|
  json.set! :id, invoice_request.id
  json.set! :text, invoice_request.to_s
end

json.pagination do
  json.set! :more, !@invoice_requests.last_page?
end
