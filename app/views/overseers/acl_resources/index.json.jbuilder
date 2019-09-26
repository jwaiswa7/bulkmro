json.data (@acl_resources) do |acl_resource|
  json.array! [
                  [
                      if is_authorized(acl_resource, 'show')
                        row_action_button_without_fa(overseers_acl_resource_path(acl_resource), 'bmro-icon-table bmro-icon-used-view', 'View Resource', 'info', :_blank)
                      end,
                      if is_authorized(acl_resource, 'edit')
                        row_action_button_without_fa(edit_overseers_acl_resource_path(acl_resource), 'bmro-icon-table bmro-icon-pencil', 'Edit Resource', 'warning', :_blank)
                      end,
                      if is_authorized(acl_resource, 'destroy')
                        row_action_button_without_fa(overseers_acl_resource_path(acl_resource), 'bmro-icon-table bmro-icon-used-trash', 'Delete Resource', 'primary', :_blank, 'delete')
                      end
                  ].join(' '),
                  acl_resource.resource_model_name,
                  acl_resource.resource_model_alias,
                  acl_resource.resource_action_name,
                  acl_resource.resource_action_alias,
                  format_date(acl_resource.created_at),
                  format_date(acl_resource.updated_at),
                  acl_resource.created_by.present? ? acl_resource.created_by.full_name : '-',
                  acl_resource.updated_by.present? ? acl_resource.updated_by.full_name : '-'
              ]
end

json.recordsTotal @acl_resources.count
json.recordsFiltered @acl_resources.total_count
json.draw params[:draw]