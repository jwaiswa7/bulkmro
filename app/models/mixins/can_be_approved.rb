# frozen_string_literal: true

module Mixins::CanBeApproved
  extend ActiveSupport::Concern

  included do
    has_one :approval, class_name: self::APPROVALS_CLASS, dependent: :destroy

    scope :approved, -> { left_outer_joins(:approval).where.not([self.class.to_s.split('::')[0].underscore.downcase, 'approvals'].join('_') => { id: nil }) }
    scope :not_approved, -> { left_outer_joins(:approval).where([self.class.to_s.split('::')[0].underscore.downcase, 'approvals'].join('_') => { id: nil }) }

    def approved?
      approval.present?
    end

    def not_approved?
      !approved?
    end
  end
end
