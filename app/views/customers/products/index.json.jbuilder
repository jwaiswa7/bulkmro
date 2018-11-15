json.data (@products) do |product|
  json.array! [
                  [
                      row_action_button(customers_product_path(product), 'eye', 'View Product', 'info'),
                      row_action_button(customers_cart_items_path(product_id: product.id, quantity: 1), 'shopping-cart', 'Add to Cart', 'success', '_self', :post, true)
                  ].join(' '),
                  product.name,
                  product.sku,
                  product.category.name,
                  format_date(product.created_at),
                  format_date(product.approval.try(:created_at))
              ]
end

json.recordsTotal @products.count
json.recordsFiltered @indexed_products.total_count
json.draw params[:draw]