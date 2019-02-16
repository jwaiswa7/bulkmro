json.data (@products) do |product|
  json.array! [
                  [
                      if policy(product).show?
                        row_action_button(overseers_product_path(product), 'eye', 'View Product', 'info')
                      end,
                      if policy(product).edit?
                        row_action_button(edit_overseers_product_path(product), 'pencil', 'Edit Product', 'warning')
                      end,
                      if policy(product).comments?
                        row_action_button(overseers_product_comments_path(product), 'comment-lines', 'View Comments', 'dark')
                      end,
                      if policy(product).sku_purchase_history?
                        row_action_button(sku_purchase_history_overseers_product_path(product), 'history', 'View Purchase History', 'outline-dark')
                      end
                  ].join(' '),
                  link_to(product.name, overseers_product_path(product), target: '_blank'),
                  product.sku,
                  link_to(product.brand.to_s, overseers_brand_path(product.brand), target: '_blank'),
                  link_to(product.category.name, overseers_category_path(product.category), target: '_blank'),
                  product.mpn,
                  format_boolean(product.is_active?),
                  format_boolean_label(product.synced?, 'synced'),
                  format_succinct_date(product.created_at),
                  format_succinct_date(product.approval.try(:created_at))
              ]
end


json.recordsTotal @products.model.all.count
json.recordsFiltered @indexed_products.total_count
json.draw params[:draw]
