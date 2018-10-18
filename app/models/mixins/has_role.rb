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
        sales: 40,
        outside_sales_team_leader: 50,
        inside_sales_team_leader: 60,
        procurement: 65,
        accounts: 70,
        logistics: 75,
        cataloging: 80
    }

    scope :administrators, -> { admin }

    scope :managers, -> { where('role IN (?)', MANAGER_ROLES.map { |r| self.roles[r] }) }
    scope :managers_and_obj, -> (obj) {where('role IN (?) OR id = ?', MANAGER_ROLES.map { |r| Overseer.roles[r] }, obj.try(:id))}

    scope :people, -> { where('role NOT IN (?)', MANAGER_ROLES.map { |r| self.roles[r] }) }

    scope :executive, -> { where('role IN (?)', EXECUTIVE_ROLES.map { |r| self.roles[r] }) }

    scope :inside, -> { where('role IN (?)', INSIDE_ROLES.map { |r| self.roles[r] }) }
    scope :inside_and_obj, -> (obj) {where('role IN (?) OR id = ?', INSIDE_ROLES.map { |r| Overseer.roles[r] }, obj.try(:id))}

    scope :outside, -> { where('role IN (?)', OUTSIDE_ROLES.map { |r| self.roles[r] }) }
    scope :outside_and_obj, -> (obj) {where('role IN (?) OR id = ?', OUTSIDE_ROLES.map { |r| Overseer.roles[r] }, obj.try(:id))}

    MANAGER_ROLES = %w(admin inside_sales_manager outside_sales_manager)
    INSIDE_ROLES = %w(inside_sales_executive inside_sales_team_leader inside_sales_manager)
    OUTSIDE_ROLES = %w(outside_sales_executive outside_sales_team_leader outside_sales_manager)
    EXECUTIVE_ROLES =  INSIDE_ROLES + OUTSIDE_ROLES
    def administrator?
      admin?
    end

    def executive?
      role.in? EXECUTIVE_ROLES
    end

    def manager?
      role.in? MANAGER_ROLES
    end

    def person?
      true
    end
  end
end