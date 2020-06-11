
class Services::Shared::Migrations::AccountsAclChangeForDashboard < Services::Shared::Migrations::Migrations
  def set_acl_for_manager_and_leadership
    admin_role_resources = AclRole.where(role_name: 'Admin').last.role_resources
    role = ['Account Manager', 'Accounts Leadership']
    role.each do |role_name|
      ss = AclRole.where(role_name: role_name).last
      ss.role_resources = admin_role_resources
      ss.save!
    end
  end
end
