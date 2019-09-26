json.data (@overseers) do |overseer|
  json.array! [
                  [
                      if is_authorized('overseer', 'show')
                        row_action_button_without_fa(overseers_overseer_path(overseer), 'bmro-icon-table bmro-icon-used-view', 'View Overseer', 'info')
                      end,
                      if is_authorized('overseer', 'edit')
                        row_action_button_without_fa(edit_overseers_overseer_path(overseer), 'bmro-icon-table bmro-icon-pencil', 'Edit Overseer', 'warning')
                      end,
                      if is_authorized('overseer', 'edit') && policy(overseer).edit_acl?
                        row_action_button(edit_acl_overseers_overseer_path(overseer), 'bmro-icon-table bmro-icon-lock', 'Edit ACL', 'success')
                      end,
                      if is_authorized('overseer', 'can_add_edit_target') && policy(overseer).can_add_edit_target?
                        overseer.annual_targets.present? ? row_action_button(overseers_annual_target_path(overseer.annual_targets.last), 'bullseye', 'View Target', 'warning') : row_action_button(new_overseers_annual_target_path(overseer_id: overseer), 'bullseye', 'Add Target', 'danger')
                      end,
                      if is_authorized('overseer', 'change_password') && policy(overseer).change_password?
                        row_action_button(change_password_overseers_overseer_path(overseer), 'key', 'Edit Password Overseer', 'danger')
                      end
                  ].join(' '),
                  overseer.hierarchy_to_s,
                  overseer.email,
                  if overseer.acl_role.present?
                    overseer.acl_role.role_name
                  end,
                  format_succinct_date(overseer.created_at),
                  if overseer.acl_updated_by.present?
                    Overseer.find(overseer.acl_updated_by).full_name
                  else
                    'System'
                  end,
                  if overseer.acl_updated_at.present?
                    format_succinct_date(overseer.acl_updated_at)
                  else
                    '-'
                  end
              ]
end

json.recordsTotal @overseers.model.all.count
json.recordsFiltered @overseers.total_count
json.draw params[:draw]
