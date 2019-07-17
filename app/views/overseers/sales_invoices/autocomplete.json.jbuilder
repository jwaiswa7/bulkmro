json.results(@sales_invoices) do |sales_invoice|
  json.set! :id, sales_invoice.id
  json.set! :text, sales_invoice.invoice_number
end

json.pagination do
  json.set! :more, !@sales_invoices.last_page?
end
