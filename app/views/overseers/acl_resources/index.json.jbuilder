json.data (@acl_resources) do |acl_resource|
  json.array! [
                  [
                      if is_authorized(acl_resource, 'edit')
                        row_action_button(edit_overseers_acl_resource_path(acl_resource), 'pencil', 'Edit Resource', 'warning', :_blank)
                      end
                  ].join(' '),
                  acl_resource.resource_model_name,
                  acl_resource.resource_action_name,
                  format_date(acl_resource.created_at),
                  format_date(acl_resource.updated_at),
                  acl_resource.created_by.full_name,
                  acl_resource.updated_by.full_name
              ]
end

json.recordsTotal @acl_resources.count
json.recordsFiltered @acl_resources.total_count
json.draw params[:draw]