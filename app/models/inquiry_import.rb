class InquiryImport < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry

  validates_presence_of :import_text
  validates_presence_of :import_type

  enum import_type: { excel: 10, list: 20 }

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.import_type ||= :excel
  end
end
