class Services::Shared::Migrations::AclMigrations < Services::Shared::BaseService
  def create_acl_roles

    all_acl_resources = Settings.acl.default_resources

    roles = [
        'left',
        'admin',
        'inside_sales_executive',
        'inside_sales_manager',
        'outside_sales_executive',
        'outside_sales_manager',
        'outside_sales_team_leader',
        'inside_sales_team_leader',
        'procurement',
        'accounts',
        'logistics',
        'cataloging',
        'hr'
    ]

    roles.each do |role|
      AclRole.where(:role_name => role).first_or_create! do |ar|
        ar.update_attributes(:role_resources => all_acl_resources)
      end
    end
  end
end
