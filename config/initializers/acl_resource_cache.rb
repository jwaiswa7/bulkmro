resource_model = defined? AclResource
if resource_model.present?
  #create acl resource cache
  Rails.cache.fetch('acl_resource_json', expires_in: 3.hours) do
    AckResource.acl_resource_json
  end

  Rails.cache.fetch('acl_menu_resource_json', expires_in: 3.hours) do
    AckResource.acl_menu_resource_json
  end

  Rails.cache.fetch('acl_resource_ids', expires_in: 3.hours) do
    AckResource.acl_resource_ids
  end
end