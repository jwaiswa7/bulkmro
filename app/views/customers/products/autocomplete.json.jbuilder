json.results(@products) do |product|
  json.set! :id, product.id
  json.set! :text, product.with_images_to_s
end

json.pagination do
  json.set! :more, !@indexed_products.last_page?
end