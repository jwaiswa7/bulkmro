json.data (@products) do |product|
  json.array! [
                  format_date(product.created_at),
                  product.name,
                  product.brand.to_s,
                  product.sku,
                  product.suppliers.size,
                  [
                      if policy(product).edit?
                        row_action_button(edit_overseers_product_path(product), 'pencil', 'Edit', 'warning')
                      end,
                      if policy(product).new_comment?
                        row_action_button(new_overseers_product_comment_path(product), 'comment-lines', 'New Comments', 'success')
                      end
                  ].join(' ')
              ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @products.total_count
json.draw params[:draw]