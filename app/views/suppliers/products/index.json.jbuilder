json.data (@supplier_products) do |supplier_product|
  json.array! [
                  [
                      row_action_button(suppliers_products_path(supplier_product), 'eye', 'View Product', 'info'),
                  ].join(' '),
                  supplier_product.product.name.to_s,
                  supplier_product.sku,
                  (supplier_product.supplier_price || supplier_product.product.latest_unit_cost_price.to_f),
                  format_boolean_label(supplier_product.product.synced?, 'synced'),
                  format_date(supplier_product.product.created_at)
              ]
end

json.recordsTotal @supplier_products.count
json.recordsFiltered @supplier_products.total_count
json.draw params[:draw]
