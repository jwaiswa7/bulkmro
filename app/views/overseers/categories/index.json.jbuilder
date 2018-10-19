json.data (@categories) do |category|
  json.array! [
                  [
                      if policy(category).edit?
                        row_action_button(edit_overseers_category_path(category), 'pencil', 'Edit Category', 'warning')
                      end,
                  ].join(' '),
                  category.to_s,
                  format_date(category.created_at)
              ]
end

json.recordsTotal @categories.model.all.count
json.recordsFiltered @categories.total_count
json.draw params[:draw]