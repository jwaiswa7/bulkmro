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
                  link_to(brand.to_s, overseers_brand_path(brand)),
                  format_boolean(brand.is_active?),
                  format_boolean_label(brand.synced?, 'synced'),
                  format_succinct_date(brand.created_at)
              ]
end

json.recordsTotal @brands.model.all.count
json.recordsFiltered @brands.total_count
json.draw params[:draw]
