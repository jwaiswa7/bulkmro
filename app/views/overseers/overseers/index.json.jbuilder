json.data (@overseers) do |overseer|
  json.array! [
                  [
                      if is_authorized('overseer','edit')
                        row_action_button(edit_overseers_overseer_path(overseer), 'pencil', 'Edit Overseer', 'warning')
                      end,
                      if is_authorized('overseer','edit') && policy(overseer).edit_acl?
                        row_action_button(edit_acl_overseers_overseer_path(overseer), 'lock', 'Edit ACL', 'success')
                      end,
                      if policy(overseer).add_password_form?
                        row_action_button(add_password_form_overseers_overseer_path(overseer), 'pencil', 'EditPassword Overseer', 'danger')
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
