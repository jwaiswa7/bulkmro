json.results(@products) do |product|
  next if (product.send(@label)&.strip == nil || product.send(@label)&.strip == "")
  json.set! :id, product.id
  json.set! :text, product.send(@label)
  json.set! :'data-images', product.images.count
end
json.pagination do
  json.set! :more, !@indexed_products.last_page?
end
