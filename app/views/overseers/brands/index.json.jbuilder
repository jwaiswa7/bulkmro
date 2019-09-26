json.data (@brands) do |brand|
  json.array! [
                  [
                      if is_authorized(brand, 'show')
                        row_action_button_without_fa(overseers_brand_path(brand), 'bmro-icon-table bmro-icon-used-view', 'View Details', 'info', :_blank)
                      end,
                      if is_authorized(brand, 'edit')
                        row_action_button_without_fa(edit_overseers_brand_path(brand), 'bmro-icon-table bmro-icon-pencil', 'Edit Brand', 'warning', :_blank)
                      end
                  ].join(' '),
                  link_to(brand.to_s, overseers_brand_path(brand)),
                  format_boolean_label(brand.synced?, 'synced'),
                  format_boolean(brand.is_active),
                  format_succinct_date(brand.created_at)
              ]
end

json.recordsTotal @brands.model.all.count
json.recordsFiltered @brands.total_count
json.draw params[:draw]
