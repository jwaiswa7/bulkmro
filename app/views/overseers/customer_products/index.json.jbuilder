json.data (@products) do |customer_product|
  json.array! [

                  [
                      if policy(customer_product).show?
                        row_action_button(overseers_customer_product_path(customer_product), 'fal fa-eye', 'View product', 'dark')
                      end,
                      if policy(customer_product).edit?
                        row_action_button(edit_overseers_customer_product_path(customer_product), 'pencil', 'Edit product', 'warning')
                      end,
                      if policy(customer_product).destroy?
                        row_action_button(overseers_customer_product_path(customer_product, company_id: customer_product.company_id),'trash', 'Delete product', 'danger', '' ,:delete)
                      end
                  ].join(' '),
                  customer_product.name.to_s.truncate(50),
                  customer_product.sku,
                  customer_product.customer_price,
                  format_boolean_label(customer_product.product.synced?, 'synced'),
                  format_date(customer_product.product.created_at)
              ]
end

json.recordsTotal @products.model.all.count
json.recordsFiltered @products.total_count
json.draw params[:draw]