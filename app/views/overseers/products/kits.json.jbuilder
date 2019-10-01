json.data (@products) do |product|
  json.array! [
      [
          if is_authorized(product, 'show') && policy(product).show?
            row_action_button_without_fa(overseers_product_path(product), 'bmro-icon-table bmro-icon-used-view', 'View Product', 'info')
          end,
          if is_authorized(product, 'edit') && policy(product).edit?
            row_action_button_without_fa(edit_overseers_product_path(product), 'bmro-icon-table bmro-icon-pencil', 'Edit Product', 'warning')
          end,
          if is_authorized(product, 'comments') && policy(product).comments?
            row_action_button_without_fa(overseers_product_comments_path(product), 'bmro-icon-table bmro-icon-comment', 'View Comments', 'dark')
          end
      ].join(' '),
      product.name,
      product.sku,
      product.brand.to_s,
      product.category.name,
      format_succinct_date(product.created_at)
  ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @products.total_count
json.draw params[:draw]
