# frozen_string_literal: true

module Mixins::Customers::CanBeStamped
  extend ActiveSupport::Concern

  included do
    attr_accessor :contact

    belongs_to :created_by, class_name: 'Contact', foreign_key: 'created_by_id', required: false
    belongs_to :updated_by, class_name: 'Contact', foreign_key: 'updated_by_id', required: false

    after_initialize :set_created_by, if: :new_record_and_contact_defined?
    before_save :set_updated_by, if: :contact_defined?
    before_create :set_created_by, if: :contact_defined?

    def contact_defined?
      contact.present?
    end

    def new_record_and_contact_defined?
      new_record? && contact_defined?
    end

    def set_updated_by
      assign_attributes(updated_by: contact)
    end

    def set_created_by
      assign_attributes(created_by: contact)
    end
  end
end
