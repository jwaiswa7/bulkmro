json.data (@products) do |product|
  json.array! [
                  [
                      if policy(product).show?
                        row_action_button(overseers_product_path(product), 'eye', 'View Product', 'dark')
                      end,
                      if policy(product).edit?
                        row_action_button(edit_overseers_product_path(product), 'pencil', 'Edit Product', 'warning')
                      end,
                      if policy(product).comments?
                        row_action_button(overseers_product_comments_path(product), 'comment-lines', 'View Comments', 'dark')
                      end,
                      if product.inquiry_products.any? && policy(product).view_purchase_history?
                        row_action_button(view_purchase_history_overseers_product_path(product), 'history', 'View Purchase History', 'outline-dark')
                      end
                  ].join(' '),
                  product.name.truncate(30),
                  product.sku,
                  product.brand.to_s,
                  product.category.name,
                  format_date(product.created_at),
                  format_date(product.approval.try(:created_at))
              ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @indexed_products.total_count
json.draw params[:draw]