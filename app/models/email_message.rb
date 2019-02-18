# frozen_string_literal: true

class EmailMessage < ApplicationRecord
  belongs_to :overseer, required: false
  belongs_to :contact

  has_many_attached :files

  belongs_to :inquiry, required: false
  belongs_to :sales_quote, required: false

  validates_presence_of :from, :to, :subject

  after_initialize :set_defaults, if: :new_record?
  def set_defaults
    self.subject ||= inquiry.subject if inquiry.present?

    self.from ||= overseer.email if overseer.present?

    self.to ||= contact.email if contact.present?

    self.auto_attach ||= false
  end
end
