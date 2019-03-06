json.results(@payment_options) do |payment_option|
  json.set! :id, payment_option.id
  json.set! :text, payment_option.name.to_s
end

json.pagination do
  json.set! :more, !@payment_options.last_page?
end
