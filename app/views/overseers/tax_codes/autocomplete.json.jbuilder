

json.results(@tax_codes) do |tax_code|
  json.set! :id, tax_code.id
  json.set! :text, tax_code.to_s
  json.set! :'data-tax-percentage', tax_code.tax_percentage
end

json.pagination do
  json.set! :more, !@tax_codes.last_page?
end
