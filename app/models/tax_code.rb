class TaxCode < ApplicationRecord
  pg_search_scope :locate, :against => [:code, :description], :using => { :tsearch => { :prefix => true, :any_word => true } }

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
    "#{self.code} (#{self.gst_rate})"
  end

  def gst_rate
    self.tax_percentage ? "GST #{self.tax_percentage}%" : ' GST N/A'
  end
end