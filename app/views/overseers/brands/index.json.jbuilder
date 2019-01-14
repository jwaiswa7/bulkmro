json.data (@brands) do |brand|
  json.array! [
                  [
                      if policy(brand).show?
                        row_action_button(overseers_brand_path(brand), 'eye', 'View Details', 'info', :_blank)
                      end,
                      if policy(brand).edit?
                        row_action_button(edit_overseers_brand_path(brand), 'pencil', 'Edit Brand', 'warning', :_blank)
                      end
                  ].join(' '),
                  brand.to_s,
                  format_boolean_label(brand.synced?, 'synced'),
                  format_date(brand.created_at)
              ]
end

json.recordsTotal @brands.model.all.count
json.recordsFiltered @brands.total_count
json.draw params[:draw]