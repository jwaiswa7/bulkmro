module Mixins::CanBeApproved
  extend ActiveSupport::Concern

  included do
    scope :approved, -> { left_outer_joins(:approval).where.not(approvals_table => { id: nil }) }
    scope :not_approved, -> { left_outer_joins(:approval).where(approvals_table => { id: nil }) }

    def approved?
      self.approval.present?
    end

    def not_approved?
      !approved?
    end

    def self.approvals_table
      nil
    end
  end
end