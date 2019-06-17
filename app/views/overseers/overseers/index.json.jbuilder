json.data (@overseers) do |overseer|
  json.array! [
                  [
                      if policy(overseer).show?
                        row_action_button(overseers_overseer_path(overseer), 'eye', 'View Overseer', 'info')
                      end,
                      if policy(overseer).edit?
                            row_action_button(edit_overseers_overseer_path(overseer), 'pencil', 'Edit Overseer', 'warning')
                      end,
                      if policy(overseer).can_add_edit_target?
                        overseer.annual_targets.present? ? '' : row_action_button(new_overseers_annual_target_path(overseer_id: overseer), 'bullseye', 'Add Target', 'danger')
                      end,
                  ].join(' '),
                  overseer.hierarchy_to_s,
                  format_enum(overseer.role),
                  format_succinct_date(overseer.created_at)
              ]
end

json.recordsTotal @overseers.model.all.count
json.recordsFiltered @overseers.total_count
json.draw params[:draw]
