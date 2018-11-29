json.data (@products) do |product|
  json.array! [
                  [
                      row_action_button(customers_product_path(product), 'eye', 'View Product', 'info'),
                      link_to("","#quantityModal", :title => 'Add to Cart', :class => "btn btn-sm btn-success fal fa-shopping-cart", "data-toggle" => "modal")
                  ].join(' '),
                  product.name,
                  product.sku,
                  product.category.name,
                  format_date(product.created_at),
                  format_date(product.approval.try(:created_at))
              ]
end

json.recordsTotal @products.count
json.recordsFiltered @indexed_products.total_count
json.draw params[:draw]