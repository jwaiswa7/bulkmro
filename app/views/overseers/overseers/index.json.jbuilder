json.data (@overseers) do |overseer|
  json.array! [
                  [
                      if policy(overseer).edit?
                        row_action_button(edit_overseers_overseer_path(overseer), 'pencil', 'Edit Overseer', 'warning')
                      end,
                  ].join(' '),
                  overseer.hierarchy_to_s,
                  format_enum(overseer.role),
                  format_date(overseer.created_at)
              ]
end

json.recordsTotal @overseers.model.all.count
json.recordsFiltered @overseers.total_count
json.draw params[:draw]
