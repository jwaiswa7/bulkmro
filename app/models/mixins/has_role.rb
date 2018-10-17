module Mixins::HasRole
  extend ActiveSupport::Concern

  included do
    enum role: {
        left: 5,
        admin: 10,
        inside_sales: 20,
        inside_sales_head: 25,
        outside_sales: 30,
        outside_sales_head: 35,
        sales: 40,
        outside_sales_manager: 50,
        inside_sales_manager: 60,
        procurement: 65,
        accounts: 70,
        logistics: 75,
        cataloging: 80
    }

    scope :administrators, -> { admin }

    scope :managers, -> { where('role IN (?)', manager_roles.map { |r| self.roles[r] }) }
    scope :managers_and_obj, -> (obj) {where('role IN (?) OR id = ?', manager_roles.map { |r| Overseer.roles[r] }, obj.try(:id))}

    scope :people, -> { where('role NOT IN (?)', manager_roles.map { |r| self.roles[r] }) }

    scope :inside, -> { where('role IN (?)', inside_roles.map { |r| self.roles[r] }) }
    scope :inside_and_obj, -> (obj) {where('role IN (?) OR id = ?', inside_roles.map { |r| Overseer.roles[r] }, obj.try(:id))}

    scope :outside, -> { where('role IN (?)', outside_roles.map { |r| self.roles[r] }) }
    scope :outside_and_obj, -> (obj) {where('role IN (?) OR id = ?', outside_roles.map { |r| Overseer.roles[r] }, obj.try(:id))}

    def manager_roles
      %w(admin inside_sales_head outside_sales_head inside_sales_manager outside_sales_head)
    end

    def inside_roles
      %w(inside_sales inside_sales_manager inside_sales_head)
    end

    def outside_roles
      %w(outside_sales outside_sales_manager outside_sales_head)
    end

    def administrator?
      admin?
    end

    def manager?
      role.in? sales_manager_roles
    end

    def person?
      !role.in? sales_manager_roles
    end
  end
end