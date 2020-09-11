class Services::Shared::Migrations::AddDeliveryChallanAcl < Services::Shared::Migrations::Migrations
  def set_acl_for_delivery_challan
    acl_resources = ["index","index_delivery_challans"]
    acl_resources.each do |acl_resource|
      acl_resource_create = AclResource.create(resource_model_name: 'delivery_challan', resource_action_name: acl_resource)
      acl_resource_create.save
    end

    roles = ['Admin']

    roles.each do |role|
      acl_role = AclRole.where(role_name: role.to_s).first
      resources = acl_role.role_resources
      acl_resource_ids = AclResource.where(resource_model_name: "delivery_challan").pluck(:id)
      acl_resource_ids.each do |acl_resource_id|
        resources << acl_resource_id.to_s
      end
      acl_role.role_resources = resources.to_json
      acl_role.save
    end
  end
end
