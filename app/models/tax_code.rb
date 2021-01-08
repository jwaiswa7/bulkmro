class TaxCode < ApplicationRecord
  pg_search_scope :locate, against: [:code, :description, :tax_percentage], using: { tsearch: { prefix: true, any_word: true } }
  update_index('tax_codes#tax_code') { self }
  include Mixins::CanBeActivated

  has_many :products

  validates_presence_of :code, :remote_uid, :tax_percentage, :description
  validate :code_validation
  scope :with_includes, -> { includes(:products) }
  scope :latest_taxcode, -> {where('created_at > ?', '2021-01-01 00:00:00')}
  after_initialize :set_defaults, if: :new_record?
  def set_defaults
    self.is_service ||= false
    self.is_pre_gst ||= false
  end

  def self.default
    first
  end

  def code_validation
    if is_service.present? && is_service && (code.length < 6 || code.length > 6)
      errors.add(:code, 'must be 6 digit')
    elsif !is_service.present? && !is_service && (code.length < 8 || code.length > 8)
      errors.add(:code, 'must be 8 digit')
    end
  end

  def to_s
    "#{self.code}"
  end
end
