json.data (@customer_products) do |customer_product|
  json.array! [
                  [
                      row_action_button(customers_customer_product_path(customer_product), 'eye', 'View Product', 'info'),
                  ].join(' '),
                  customer_product.name.to_s.truncate(50),
                  customer_product.sku,
                  customer_product.product.latest_unit_cost_price.to_f,
                  format_boolean_label(customer_product.product.synced?, 'synced'),
                  format_date(customer_product.product.created_at)
              ]
end

json.recordsTotal @customer_products.count
json.recordsFiltered @indexed_customer_products.total_count
json.draw params[:draw]