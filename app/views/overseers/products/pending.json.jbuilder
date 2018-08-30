json.data (@products) do |product|
  json.array! [
                  format_date(product.created_at),
                  product.name,
                  product.brand.to_s,
                  product.sku,
                  product.suppliers.size,
                  [
                      if policy(product).new_approval?
                        row_action_button(new_overseers_product_approval_path(product), 'plus', 'Edit', 'warning')
                      end,
                  ].join(' ')
              ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @products.total_count
json.draw params[:draw]