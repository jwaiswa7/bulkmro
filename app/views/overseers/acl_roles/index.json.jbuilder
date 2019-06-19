json.data (@acl_roles) do |acl_role|
  json.array! [
                  [
                      if is_authorized('acl_role', 'edit')
                        row_action_button(edit_overseers_acl_role_path(acl_role), 'pencil', 'Edit Role', 'warning')
                      end,
                  ].join(' '),
                  acl_role.role_name.titleize,
                  format_date_time_meridiem(acl_role.created_at),
                  format_date_time_meridiem(acl_role.updated_at),
                  acl_role.created_by.present? ? acl_role.created_by.full_name : 'System',
                  acl_role.updated_by.present? ? acl_role.updated_by.full_name : 'System'
              ]
end

json.recordsTotal @acl_roles.all.count
json.recordsFiltered @acl_roles.total_count
json.draw params[:draw]
