

json.results(@products) do |product|
  json.set! :id, product.id
  json.set! :text, product.to_s
  json.set! :'data-images', product.images.count
end

json.pagination do
  json.set! :more, !@indexed_products.last_page?
end
