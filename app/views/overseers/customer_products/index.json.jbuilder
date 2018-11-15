json.data (@products) do |customer_product|
  json.array! [

                  [
                      if policy(customer_product).show?
                        #row_action_button(overseers_company_product_path(product.company, product), 'fal fa-eye', 'View product', 'dark')
                      end,
                      if policy(customer_product).edit?
                        #row_action_button(edit_overseers_company_product_path(product.company, product), 'pencil', 'Edit product', 'warning')
                      end,
                  ].join(' '),
                  customer_product.product.to_s.truncate(50),
                  format_boolean_label(customer_product.product.synced?, 'synced'),
                  format_date(customer_product.product.created_at)
              ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @products.total_count
json.draw params[:draw]