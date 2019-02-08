# frozen_string_literal: true

json.results(@products) do |product|
  json.set! :id, product.id
  json.set! :text, product.to_s
end

json.pagination do
  json.set! :more, !@products.last_page?
end
