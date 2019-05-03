class TaxCode < ApplicationRecord
  pg_search_scope :locate, against: [:code, :description, :tax_percentage], using: { tsearch: { prefix: true, any_word: true } }
  update_index('tax_codes#tax_code') { self }
  include Mixins::CanBeActivated

  has_many :products

  validates_presence_of :code, :remote_uid, :tax_percentage, :description
  validates :code, length: { minimum: 8, maximum: 8 }
  scope :with_includes, -> { includes(:products) }
  after_initialize :set_defaults, if: :new_record?
  def set_defaults
    self.is_service ||= false
    self.is_pre_gst ||= false
  end

  def self.default
    first
  end

  def to_s
    "#{self.code}"
  end
end
