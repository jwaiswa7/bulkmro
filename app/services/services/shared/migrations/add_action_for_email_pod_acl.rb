
class Services::Shared::Migrations::AddActionForEmailPodAcl < Services::Shared::Migrations::Migrations

  def add_action_to_sales_invoice_acl
    add_action = AclResource.create(resource_model_name: 'sales_invoice', resource_action_name: "can_send_pod_email", resource_model_alias: "Sales Invoice")
    add_action.save

    roles = ['Admin', 'Logistics']

    roles.each do |role|
      acl_role = AclRole.where(role_name: role.to_s).first
      resources = acl_role.role_resources
      resources << add_action.id.to_s
      acl_role.role_resources = resources.to_json
      acl_role.save
    end
  end
end