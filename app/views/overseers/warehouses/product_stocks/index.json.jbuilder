

json.data (@warehouse_products.order(instock: :desc)) do |warehouse_product|
  json.array! [
                  conditional_link(warehouse_product.product.name.truncate(50, separator: ' '), overseers_product_path(warehouse_product.product), policy(warehouse_product.product).show?),
                  conditional_link(warehouse_product.product.sku, overseers_product_path(warehouse_product.product), policy(warehouse_product.product).show?),
                  warehouse_product.instock,
                  warehouse_product.committed,
                  warehouse_product.ordered,
                  (warehouse_product.instock - warehouse_product.committed)
              ]
end

json.recordsTotal @warehouse_products.model.all.count
json.recordsFiltered @warehouse_products.total_count
json.draw params[:draw]
