
json.data (@warehouse_products.order(instock: :desc)) do |warehouse_product|
  json.array! [
                  (warehouse_product.product.name.truncate(50, separator: ' ')),
                  warehouse_product.product.sku,
                  number_with_delimiter(warehouse_product.instock.to_i, delimiter: ','),
                  number_with_delimiter(warehouse_product.committed.to_i, delimiter: ','),
                  number_with_delimiter(warehouse_product.ordered.to_i, delimiter: ','),
                  number_with_delimiter((warehouse_product.instock - warehouse_product.committed).to_i, delimiter: ',')
              ]
end

json.recordsTotal @warehouse_products.count
json.recordsFiltered @warehouse_products.count
json.draw params[:draw]