json.data (@customer_products) do |customer_product|
  json.array! [
                  [
                      row_action_button(customers_product_path(customer_product), 'eye', 'View Product', 'info')
                  ].join(' '),
                  customer_product.product.name.to_s,
                  customer_product.sku,
                  customer_product.brand.to_s,
                  (customer_product.customer_price || customer_product.product.latest_unit_cost_price.to_f),
                  display_stock_status(customer_product, [@phursungi_warehouse.id]),
                  format_date(customer_product.product.created_at)
              ]
end

json.recordsTotal @customer_products.count
json.recordsFiltered @indexed_customer_products.total_count
json.draw params[:draw]
