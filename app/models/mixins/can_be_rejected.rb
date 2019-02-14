# frozen_string_literal: true

module Mixins::CanBeRejected
  extend ActiveSupport::Concern

  included do
    has_one :rejection, class_name: self::REJECTIONS_CLASS, dependent: :destroy

    scope :rejected, -> { left_outer_joins(:rejection).where.not([self.class.to_s.split('::')[0].underscore.downcase, 'rejections'].join('_') => { id: nil }) }
    scope :not_rejected, -> { left_outer_joins(:rejection).where([self.class.to_s.split('::')[0].underscore.downcase, 'rejections'].join('_') => { id: nil }) }

    def rejected?
      rejection.present?
    end

    def not_rejected?
      !rejected?
    end
  end
end
