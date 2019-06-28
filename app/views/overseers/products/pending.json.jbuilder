json.data (@products) do |product|
  json.array! [
      [
          if is_authorized(product, 'show') && policy(product).show?
            row_action_button(overseers_product_path(product), 'eye', 'View Product', 'info')
          end,
          if is_authorized(product, 'edit') && policy(product).edit?
            row_action_button(edit_overseers_product_path(product), 'pencil', 'Edit Product', 'warning')
          end,
          if is_authorized(product, 'comments') && policy(product).comments?
            row_action_button(overseers_product_comments_path(product), 'comment-lines', 'View Comments', 'dark')
          end
      ].join(' '),
      link_to(product.name, overseers_product_path(product), target: '_blank'),
      product.sku,
      (product.brand.present? ? conditional_link(product.brand.to_s, overseers_brand_path(product.brand), is_authorized(product.brand, 'show')) : '-'),
      (product.category.present? ? conditional_link(product.category.name, overseers_category_path(product.category), is_authorized(product.category, 'show')) : '-'),
      format_succinct_date(product.created_at)
  ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @products.total_count
json.draw params[:draw]
