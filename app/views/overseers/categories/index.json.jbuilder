json.data (@categories) do |category|
  json.array! [
                  [
                      if policy(category).show?
                        row_action_button(overseers_category_path(category), 'fal fa-eye', 'View Category', 'info', :_blank)
                      end,
                      if policy(category).edit?
                        row_action_button(edit_overseers_category_path(category), 'pencil', 'Edit Category', 'warning', :_blank)
                      end
                  ].join(' '),
                  conditional_link(category.to_s, overseers_category_path(category), policy(category).show? ),
                  format_boolean_label(category.synced?, 'synced'),
                  format_date(category.created_at)
              ]
end

json.recordsTotal @categories.model.all.count
json.recordsFiltered @categories.total_count
json.draw params[:draw]