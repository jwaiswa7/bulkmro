json.data (@products) do |product|
  json.array! [
                  [
                      row_action_button(customers_product_path(product), 'arrow-right', 'View Product', 'dark'),
                      row_action_button(customers_cart_path(product), 'shopping-cart', 'Show Cart', 'dark'), 
                      row_action_button(customers_cart_item_path(product), 'plus', 'Add to Cart', 'dark')   
                  ].join(' '),
                  product.name,
                  product.sku,
                  product.category.name,
                  format_date(product.created_at),
                  format_date(product.approval.try(:created_at))
              ]
end

json.recordsTotal @products.all.count
json.recordsFiltered @products.total_count
json.draw params[:draw]