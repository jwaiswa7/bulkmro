json.data (@products) do |product|
  json.array! [
                  [
                      if policy(product).show?
                        row_action_button(overseers_product_path(product), 'eye', 'View Product', 'info', :_blank)
                      end,
                      if policy(product).edit?
                        row_action_button(edit_overseers_product_path(product), 'pencil', 'Edit Product', 'warning', :_blank)
                      end,
                      if policy(product).comments?
                        row_action_button(overseers_product_comments_path(product), 'comment-lines', 'View Comments', 'dark', :_blank)
                      end,
                      if policy(product).sku_purchase_history?
                        row_action_button(sku_purchase_history_overseers_product_path(product), 'history', 'View Purchase History', 'outline-dark', :_blank)
                      end,
                      if policy(product).resync_inventory?
                          row_action_button(resync_inventory_overseers_product_path(product), 'inventory', 'Resync Inventory', 'outline-dark', :_blank)
                      end
                  ].join(' '),
                  product.name,
                  product.sku,
                  product.brand.to_s,
                  product.category.name,
                  product.mpn,
                  format_boolean(product.is_active?),
                  format_boolean_label(product.synced?, 'synced'),
                  format_succinct_date(product.created_at),
                  format_succinct_date(product.approval.try(:created_at))
              ]
end
json.columnFilters [
                    [],
                    [{"source": autocomplete_overseers_products_path}],
                    [],
                    [{"source": autocomplete_overseers_brands_path}],
                    [],
                    [],
                    [],
                    [],
                    []
                   ]

json.recordsTotal @products.model.all.count
json.recordsFiltered @indexed_products.total_count
json.draw params[:draw]