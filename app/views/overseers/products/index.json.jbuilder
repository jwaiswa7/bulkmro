json.data (@products) do |product|
  json.array! [
                  format_date(product.created_at),
                  product.name,
                  product.brand.to_s,
                  product.sku,
                  product.suppliers.size,
                  [
                      row_action_button(edit_overseers_product_path(product), 'pencil', 'Edit', 'warning'),
                  ].join(' ')
              ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @products.total_count
json.draw params[:draw]