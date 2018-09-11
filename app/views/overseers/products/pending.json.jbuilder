json.data (@products) do |product|
  json.array! [
                  [
                      if policy(product).comments?
                        row_action_button(overseers_product_comments_path(product), 'comment-lines', 'View Comments', 'dark')
                      end,
                  ].join(' '),
                  product.name,
                  product.sku,
                  product.brand.to_s,
                  product.suppliers.size,
                  format_date(product.created_at)

              ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @products.total_count
json.draw params[:draw]