json.data (@products) do |supplier_product|
  json.array! [

                  [
                      if is_authorized(supplier_product, 'show')
                        row_action_button(overseers_company_supplier_product_path(supplier_product.supplier, supplier_product), 'fal fa-eye', 'View product', 'info', :_blank)
                      end,
                      if is_authorized(supplier_product, 'destroy')
                        row_action_button(overseers_company_supplier_product_path(supplier_product.supplier, supplier_product), 'trash', 'Delete product', 'danger', '', :delete)
                      end
                  ].join(' '),
                  # supplier_product.name.to_s.truncate(50),
                  link_to(supplier_product.name.to_s.truncate(50), overseers_company_supplier_product_path(supplier_product.supplier, supplier_product), target: '_blank'),
                  supplier_product.sku,
                  supplier_product.supplier_price,
                  format_boolean_label(supplier_product.product.synced?, 'synced'),
                  format_succinct_date(supplier_product.created_at)
              ]
end

json.recordsTotal @company.supplier_products.count
json.recordsFiltered @products.total_count
json.draw params[:draw]
