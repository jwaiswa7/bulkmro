json.data (@products) do |product|
  json.array! [
                  [
                      if policy(product).edit?
                        row_action_button(edit_overseers_product_path(product), 'pencil', 'Edit Product', 'warning')
                      end,
                      if policy(product).comments?
                        row_action_button(overseers_product_comments_path(product), 'comment-lines', 'View Comments', 'dark')
                      end
                  ].join(' '),
                  product.name.truncate(50),
                  product.sku,
                  product.brand.to_s,
                  product.category.to_s,
                  format_date(product.created_at),
                  format_date(product.approval.try(:created_at))
              ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @indexed_products.total_count
json.draw params[:draw]