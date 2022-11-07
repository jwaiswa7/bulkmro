json.data (@customer_products) do |customer_product|
  qty_in_stock = customer_product.product.stocks.where(warehouse_id: @phursungi_warehouse.id).sum(&:instock).to_i
  json.array! [
                  [
                      row_action_button(customers_product_path(customer_product), 'eye', 'View Product', 'info'),
                      add_to_wish_list(customer_product)
                  ].join(' '),
                  customer_product.product.name.to_s,
                  customer_product.sku,
                  customer_product.brand.to_s,
                  format_currency((customer_product.customer_price || customer_product.product.latest_unit_cost_price.to_f)),
                  display_stock_status(customer_product, [@phursungi_warehouse.id]),
                  qty_in_stock,
                  policy(:cart).add_item? ? add_to_cart(customer_product) : ""
              ]
end

json.recordsTotal @customer_products.count
json.recordsFiltered @indexed_customer_products.total_count
json.draw params[:draw]
