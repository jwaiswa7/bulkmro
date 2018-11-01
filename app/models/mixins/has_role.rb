module Mixins::HasRole
  extend ActiveSupport::Concern

  included do
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
        cataloging: 80
    }

    scope :managers, -> {where('role IN (?)', MANAGER_ROLES.map {|r| self.roles[r]})}
    scope :managers_and_obj, -> (obj) {where('role IN (?) OR id = ?', MANAGER_ROLES.map {|r| Overseer.roles[r]}, obj.try(:id))}

    scope :inside, -> {where('role IN (?)', INSIDE_ROLES.map {|r| self.roles[r]})}
    scope :inside_and_obj, -> (obj) {where('role IN (?) OR id = ?', INSIDE_ROLES.map {|r| Overseer.roles[r]}, obj.try(:id))}

    scope :outside, -> {where('role IN (?)', OUTSIDE_ROLES.map {|r| self.roles[r]})}
    scope :outside_and_obj, -> (obj) {where('role IN (?) OR id = ?', OUTSIDE_ROLES.map {|r| Overseer.roles[r]}, obj.try(:id))}

    MANAGER_ROLES = %w(admin inside_sales_manager outside_sales_manager)
    INSIDE_ROLES = %w(inside_sales_executive inside_sales_team_leader inside_sales_manager outside_sales_manager admin)
    OUTSIDE_ROLES = %w(outside_sales_executive outside_sales_team_leader outside_sales_manager inside_sales_manager admin)
    OTHER_ROLES = %w(procurement accounts logistics sales)

    def manager?
      role.in? MANAGER_ROLES
    end

    def inside?
      role.in? INSIDE_ROLES
    end

    def outside?
      role.in? OUTSIDE_ROLES
    end

    def others?
      role.in? OTHER_ROLES
    end
  end
end