module Mixins::HasRole
  extend ActiveSupport::Concern

  included do
    belongs_to :acl_role, required: false

    enum role: {
        left: 5,
        admin: 10,
        inside_sales_executive: 20,
        inside_sales_manager: 25,
        outside_sales_executive: 30,
        outside_sales_manager: 35,
        outside_sales_team_leader: 50,
        inside_sales_team_leader: 60,
        procurement: 65,
        accounts: 70,
        logistics: 75,
        cataloging: 80,
        hr: 90
    }

    scope :managers, -> { where('role IN (?)', MANAGER_ROLES.map { |r| self.roles[r] }) }
    scope :managers_and_obj, -> (obj) { where('role IN (?) OR id = ? OR email IN (?)', MANAGER_ROLES.map { |r| Overseer.roles[r] }, obj.try(:id), COMMON_OVERSEERS) }

    scope :inside, -> { where('role IN (?)', INSIDE_ROLES.map { |r| self.roles[r] }) }
    scope :inside_with_additional_overseers, -> { where('role IN (?) OR email IN (?)', INSIDE_ROLES.map { |r| self.roles[r] },  COMMON_OVERSEERS)}
    scope :target_inside, -> { where('role IN (?)', TARGET_INSIDE_ROLES.map { |r| self.roles[r] }) }
    scope :inside_and_obj, -> (obj) { where('role IN (?) OR id = ? OR email IN (?)', INSIDE_ROLES.map { |r| Overseer.roles[r] }, obj.try(:id), COMMON_OVERSEERS) }

    scope :outside, -> { where('role IN (?)', OUTSIDE_ROLES.map { |r| self.roles[r] }) }
    scope :outside_with_additional_overseers, -> { where('role IN (?) OR email IN (?)', OUTSIDE_ROLES.map { |r| self.roles[r] }, COMMON_OVERSEERS) }
    scope :target_outside, -> { where('role IN (?)', TARGET_OUTSIDE_ROLES.map { |r| self.roles[r] }) }
    scope :outside_and_obj, -> (obj) { where('role IN (?) OR id = ? OR email IN (?)', OUTSIDE_ROLES.map { |r| Overseer.roles[r] }, obj.try(:id),  COMMON_OVERSEERS) }

    scope :pipeline_executives, -> { where('role IN (?)', PIPELINE_EXECUTIVES.map { |r| self.roles[r] }) }

    scope :with_activity, -> { where('role IN (?)', TARGET_OUTSIDE_ROLES.map { |r| self.roles[r] }) }

    MANAGER_ROLES = %w(admin inside_sales_manager outside_sales_manager)
    LEADER_ROLES = %w(inside_sales_team_leader outside_sales_team_leader)
    INSIDE_ROLES = %w(inside_sales_executive inside_sales_team_leader inside_sales_manager outside_sales_manager admin)
    OUTSIDE_ROLES = %w(outside_sales_executive outside_sales_team_leader outside_sales_manager inside_sales_manager admin)
    TARGET_INSIDE_ROLES = %w(inside_sales_executive inside_sales_team_leader inside_sales_manager)
    TARGET_OUTSIDE_ROLES = %w(outside_sales_executive outside_sales_team_leader outside_sales_manager)
    OTHER_ROLES = %w(procurement accounts logistics sales)
    SALES_ROLES = %w[inside_sales_executive inside_sales_team_leader inside_sales_manager outside_sales_executive outside_sales_team_leader outside_sales_manager]

    PIPELINE_EXECUTIVES = %w(inside_sales_executive outside_sales_executive)
    LOGISTICS_ROLES = ['Logistics', 'Admin-Leadership Team', 'Admin', 'Inside Sales and Logistic Manager', 'Inside Sales Executive', 'Inside Sales Manager', 'Outside Sales Manager']
    CATALOG_ROLES = ['Admin', 'Cataloging']
    ACCOUNT_ROLES = ['Accounts', 'Admin']
    ACCOUNT_ACL_ADMIN_ROLES = ['Account Manager', 'Accounts Leadership']
    COMMON_OVERSEERS = ['rn.prasad@bulkmro.com', 'tejaswi.patil@bulkmro.com', 'swati.bhosale@bulkmro.com', 'mithun
.trisule@bulkmro.com', 'srikant.desai@bulkmro.com', 'atul.thakur@bulkmro.com', 'rajesh.sharma@bulkmro.com', 'lalit
.dhingra@bulkmro.com', 'vivek.syal@bulkmro.com', 'ashish.pareek@bulkmro.com', 'nutan.bala@bulkmro.com']

    def sales?
      role.in? SALES_ROLES
    end

    def manager?
      role.in? MANAGER_ROLES
    end

    def leader?
      role.in? LEADER_ROLES
    end

    def inside?
      role.in? INSIDE_ROLES
    end

    def outside?
      role.in? OUTSIDE_ROLES
    end

    def target_inside?
      role.in? TARGET_INSIDE_ROLES
    end

    def target_outside?
      role.in? TARGET_OUTSIDE_ROLES
    end

    def logistics?
      acl_role.role_name.in? LOGISTICS_ROLES
    end

    def cataloging?
      acl_role.role_name.in? CATALOG_ROLES
    end

    def allow_inquiries?
      admin? || cataloging? || logistics? || accounts?
    end

    def manager_or_cataloging?
      manager? || cataloging?
    end

    def others?
      role.in? OTHER_ROLES
    end

    def accounts?
      acl_role.role_name.in? ACCOUNT_ROLES
    end

    # def acl_accounts?
    #   acl_role.role_name.in? ACCOUNT_ACL_ROLES
    # end

    def accounts_role_for_dashboard?
      if acl_role.role_name.in? ACCOUNT_ACL_ADMIN_ROLES
        true
      else
        account_task_hash = Settings.account_dashboard_task
        account_persons_arr = ActiveSupport::JSON.decode(account_task_hash).keys
        email.in? account_persons_arr
      end
    end
  end
end
