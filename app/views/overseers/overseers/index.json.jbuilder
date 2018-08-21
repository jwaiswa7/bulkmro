json.data (@overseers) do |overseer|
  json.array! [
                  format_date(overseer.created_at),
                  overseer.hierarchy_to_s,
                  format_enum(overseer.role),
                  [
                      row_action_button(edit_overseers_overseer_path(overseer), 'pencil', 'Edit', 'warning'),
                  ].join(' ')
              ]
end

json.recordsTotal @overseers.model.all.count
json.recordsFiltered @overseers.total_count
json.draw params[:draw]