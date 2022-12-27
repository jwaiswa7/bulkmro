# frozen_string_literal: true

module Mixins::IsAnImport
  extend ActiveSupport::Concern

  included do
    has_one_attached :file

    enum import_type: { excel: 10, list: 20, rfq: 30 }

    validates_presence_of :import_type
    validates :file, file_content_type: { allow: ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'] }, if: -> { file.attached? }
    validate :has_file_attachment?, if: :excel?

    def has_file_attachment?
      errors.add(:base, 'File is required') unless file.attached?
    end

    after_initialize :set_is_an_import_defaults, if: :new_record?

    def set_is_an_import_defaults
      self.import_type ||= :excel
    end
  end
end
