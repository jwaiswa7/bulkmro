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
