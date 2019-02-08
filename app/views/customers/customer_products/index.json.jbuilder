# frozen_string_literal: true

json.data (@customer_products) do |customer_product|
  json.array! [
                  [
                      row_action_button(customers_product_path(customer_product), "eye", "View Product", "info"),
                      link_to("", to_cart_customers_product_path(customer_product), status: "Add to Cart", class: "btn btn-sm btn-success fal fa-shopping-cart", remote: true)
                  ].join(" "),
                  customer_product.product.name.to_s,
                  customer_product.sku,
                  (customer_product.customer_price || customer_product.product.latest_unit_cost_price.to_f),
                  format_boolean_label(customer_product.product.synced?, "synced"),
                  format_date(customer_product.product.created_at)
              ]
end

json.recordsTotal @customer_products.count
json.recordsFiltered @indexed_customer_products.total_count
json.draw params[:draw]
