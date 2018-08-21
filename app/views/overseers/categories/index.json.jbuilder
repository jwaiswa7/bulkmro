json.data (@categories) do |category|
  json.array! [
                  format_date(category.created_at),
                  category.to_s,
                  [
                      row_action_button(edit_overseers_category_path(category), 'pencil', 'Edit', 'warning'),
                  ].join(' ')
              ]
end

json.recordsTotal @categories.model.all.count
json.recordsFiltered @categories.total_count
json.draw params[:draw]