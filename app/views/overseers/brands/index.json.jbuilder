json.data (@brands) do |brand|
  json.array! [
                  format_date(brand.created_at),
                  brand.to_s,
                  brand.suppliers.size,
                  brand.products.size,
                  [
                      row_action_button(edit_overseers_brand_path(brand), 'pencil', 'Edit', 'warning'),
                  ].join(' ')
              ]
end

json.recordsTotal @brands.model.all.count
json.recordsFiltered @brands.total_count
json.draw params[:draw]