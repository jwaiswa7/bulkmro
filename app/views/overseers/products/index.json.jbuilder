json.data (@products) do |product|
  json.array! [
                  [
                      if is_authorized(product, 'show')
                        row_action_button(overseers_product_path(product), 'eye', 'View Product', 'info', :_blank)
                      end,
                      if is_authorized(product, 'edit')
                        row_action_button(edit_overseers_product_path(product), 'pencil', 'Edit Product', 'warning', :_blank)
                      end,
                      if is_authorized(product, 'comments')
                        row_action_button(overseers_product_comments_path(product), 'comment-lines', 'View Comments', 'dark', :_blank)
                      end,
                      if is_authorized(product, 'sku_purchase_history')
                        row_action_button(sku_purchase_history_overseers_product_path(product), 'history', 'View Purchase History', 'outline-dark', :_blank)
                      end,
                      if is_authorized(product, 'resync_inventory')
                        row_action_button(resync_inventory_overseers_product_path(product), 'inventory', 'Resync Inventory', 'outline-dark', :_blank)
                      end
                  ].join(' '),
                  link_to(product.name, overseers_product_path(product), target: '_blank'),
                  product.sku,
                  product.brand.present? ? link_to(product.brand.to_s, overseers_brand_path(product.brand), target: '_blank') : '-',
                  product.category.present? ? link_to(product.category.name, overseers_category_path(product.category), target: '_blank') : '-',
                  product.mpn,
                  number_with_delimiter(product.total_pos, delimiter: ','),
                  number_with_delimiter(product.total_quotes, delimiter: ','),
                  format_boolean(product.is_service),
                  format_boolean_label(product.synced?, 'synced'),
                  format_boolean(product.is_active),
                  format_succinct_date(product.created_at),
                  (product.created_by || (product.inquiry_import_row.inquiry.created_by if product.inquiry_import_row)).try(:name) || '-',
                 product.approval.present? ? product.approval.created_by.name : '-',
                  format_succinct_date(product.approval.try(:created_at)),
              ]
end
json.columnFilters [
                       [],
                       [{"source": autocomplete_overseers_products_path}],
                       [{"source": autocomplete_mpn_overseers_products_path(label: :sku)}],
                       [{"source": autocomplete_overseers_brands_path}],
                       [],
                       [{"source": autocomplete_mpn_overseers_products_path(label: :mpn)}],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @products.model.all.count
json.recordsFiltered @indexed_products.total_count
json.draw params[:draw]
