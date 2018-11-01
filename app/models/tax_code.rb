class TaxCode < ApplicationRecord
  pg_search_scope :locate, :against => [:code, :description, :tax_percentage], :using => { :tsearch => { :prefix => true, :any_word => true } }

  has_many :products

  validates_presence_of :code
  validates_presence_of :remote_uid

  after_initialize :set_defaults, :if => :new_record?
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