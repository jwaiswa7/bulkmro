json.data (@products) do |customer_product|
  json.array! [

                  [
                      if is_authorized(customer_product, 'show')
                        row_action_button(overseers_company_customer_product_path(customer_product.company, customer_product), 'fal fa-eye', 'View product', 'info', :_blank)
                      end,
                      if is_authorized(customer_product, 'edit')
                        row_action_button(edit_overseers_company_customer_product_path(customer_product.company, customer_product), 'pencil', 'Edit product', 'warning', :_blank)
                      end,
                      if is_authorized(customer_product, 'destroy')
                        row_action_button(overseers_company_customer_product_path(customer_product.company, customer_product), 'trash', 'Delete product', 'danger', '', :delete)
                      end
                  ].join(' '),
                  link_to(customer_product.name.to_s.truncate(50), overseers_company_customer_product_path(customer_product.company, customer_product), target: '_blank'),
                  customer_product.sku,
                  customer_product.customer_price,
                  format_boolean_label(customer_product.product.synced?, 'synced'),
                  format_boolean(customer_product.images.present?),
                  format_succinct_date(customer_product.product.created_at)
              ]
end


json.recordsTotal @indexed_addresses.total_count
json.recordsFiltered @indexed_addresses.total_count
json.draw params[:draw]
