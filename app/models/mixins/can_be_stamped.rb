# frozen_string_literal: true

module Mixins::CanBeStamped
  extend ActiveSupport::Concern

  included do
    attr_accessor :overseer

    belongs_to :created_by, class_name: "Overseer", foreign_key: "created_by_id", required: false
    belongs_to :updated_by, class_name: "Overseer", foreign_key: "updated_by_id", required: false

    after_initialize :set_created_by_overseer, if: :new_record_and_overseer_defined?
    before_save :set_updated_by_overseer, if: :overseer_defined?
    before_create :set_created_by_overseer, if: :overseer_defined?

    def overseer_defined?
      overseer.present?
    end

    def new_record_and_overseer_defined?
      self.new_record? && overseer_defined?
    end

    def set_updated_by_overseer
      self.assign_attributes(updated_by: overseer)
    end

    def set_created_by_overseer
      self.assign_attributes(created_by: overseer)
    end
  end
end
