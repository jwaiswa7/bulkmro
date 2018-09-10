json.data (@brands) do |brand|
  json.array! [
                  [
                      row_action_button(edit_overseers_brand_path(brand), 'pencil', 'Edit', 'warning'),
                  ].join(' '),
                  brand.to_s,
                  brand.suppliers.size,
                  brand.products.size,
                  format_date(brand.created_at)
              ]
end

json.recordsTotal @brands.model.all.count
json.recordsFiltered @brands.total_count
json.draw params[:draw]