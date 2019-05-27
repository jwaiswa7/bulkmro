resource_json = []
models = []
children = []
acl_parent = []
Rails.cache.delete('acl_resource_json')
resource_model = defined? AclResource
if resource_model.present?
  Rails.cache.fetch('acl_resource_json', expires_in: 30.minutes) do
    AclResource.all.each do |acl_resource|
      if !models.include? acl_resource.resource_model_name
        if children.present? && children.size > 0
          acl_parent.children = children
          resource_json.push(acl_parent.marshal_dump)
          children = []
        end

        models << acl_resource.resource_model_name
        acl_parent = OpenStruct.new
        acl_parent.id = acl_resource.id
        acl_parent.text = acl_resource.resource_model_name
        acl_parent.checked = false
        acl_parent.hasChildren = true
      else
        acl_row = OpenStruct.new
        acl_row.id = acl_resource.id
        acl_row.text = acl_resource.resource_action_name
        acl_row.checked = false
        acl_row.hasChildren = false
        children.push(acl_row.marshal_dump)
      end
    end
    resource_json.to_json
  end
end