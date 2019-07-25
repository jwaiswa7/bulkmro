json.data (@overseers) do |overseer|
  json.array! [
                  [
                      if is_authorized('overseer', 'show')
                        row_action_button(overseers_overseer_path(overseer), 'eye', 'View Overseer', 'info')
                      end,
                      if is_authorized('overseer', 'edit')
                        row_action_button(edit_overseers_overseer_path(overseer), 'pencil', 'Edit Overseer', 'warning')
                      end,
                      if is_authorized('overseer', 'edit') && policy(overseer).edit_acl?
                        row_action_button(edit_acl_overseers_overseer_path(overseer), 'lock', 'Edit ACL', 'success')
                      end,
                      if is_authorized('overseer', 'can_add_edit_target') && policy(overseer).can_add_edit_target?
                        overseer.annual_targets.present? ? row_action_button(overseers_annual_target_path(overseer.annual_targets.last), 'bullseye', 'View Target', 'warning') : row_action_button(new_overseers_annual_target_path(overseer_id: overseer), 'bullseye', 'Add Target', 'danger')
                      end,
                      if is_authorized('overseer', 'change_password') && policy(overseer).change_password?
                        row_action_button(change_password_overseers_overseer_path(overseer), 'key', 'Edit Password Overseer', 'danger')
                      end
                  ].join(' '),
                  overseer.hierarchy_to_s,
                  if overseer.acl_role.present?
                    overseer.acl_role.role_name
                  end,
                  format_succinct_date(overseer.created_at)
              ]
end

json.recordsTotal @overseers.model.all.count
json.recordsFiltered @overseers.total_count
json.draw params[:draw]
