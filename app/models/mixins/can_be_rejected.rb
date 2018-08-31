module Mixins::CanBeRejected
  extend ActiveSupport::Concern

  included do
    class NotAllowed < StandardError; end

    scope :rejected, -> { left_outer_joins(:rejection).where.not(rejections_table => { id: nil }) }
    scope :not_rejected, -> { left_outer_joins(:rejection).where(rejections_table => { id: nil }) }

    def rejected?
      rejection.present?
    end

    def not_rejected?
      !rejected?
    end

    def self.rejections_table
      nil
    end
  end
end