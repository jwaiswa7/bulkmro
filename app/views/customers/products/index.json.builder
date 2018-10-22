json.data (@products) do |product|
  json.array! [
                  [   if policy(product).show?
                        row_action_button(product_path(product), 'eye', 'View Product', 'dark')
                      end
                  ].join(' '),
                  product.name,
                  product.sku,
                  product.category.name,
                  format_date(product.created_at),
                  format_date(product.approval.try(:created_at))
              ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @indexed_products.total_count
json.draw params[:draw]