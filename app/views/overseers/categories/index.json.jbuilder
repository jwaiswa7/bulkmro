json.data (@categories) do |category|
  json.array! [
                  [
                      if is_authorized(category, 'show')
                        row_action_button(overseers_category_path(category), 'fal fa-eye', 'View Category', 'dark', :_blank)
                      end,
                      if is_authorized(category, 'edit')
                        row_action_button(edit_overseers_category_path(category), 'pencil', 'Edit Category', 'warning', :_blank)
                      end
                  ].join(' '),
                  conditional_link(category.to_s, overseers_category_path(category), is_authorized(category, 'show')),
                  format_boolean(category.is_service),
                  format_boolean_label(category.synced?, 'synced'),
                  format_boolean(category.is_active),
                  format_succinct_date(category.created_at)
              ]
end

json.recordsTotal @categories.model.all.count
json.recordsFiltered @categories.total_count
json.draw params[:draw]
