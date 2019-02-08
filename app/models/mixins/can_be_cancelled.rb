# frozen_string_literal: true

module Mixins::CanBeCancelled
  extend ActiveSupport::Concern

  included do
    has_one :cancellation, class_name: self::REJECTIONS_CLASS, dependent: :destroy

    scope :rejected, -> { left_outer_joins(:cancellation).where.not([self.class.to_s.split("::")[0].underscore.downcase, "cancellations"].join("_") => { id: nil }) }
    scope :not_rejected, -> { left_outer_joins(:cancellation).where([self.class.to_s.split("::")[0].underscore.downcase, "cancellations"].join("_") => { id: nil }) }

    def rejected?
      cancellation.present?
    end

    def not_rejected?
      !rejected?
    end
  end
end
