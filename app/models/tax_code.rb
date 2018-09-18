class TaxCode < ApplicationRecord
  include Mixins::HasRemoteUid
  pg_search_scope :locate, :against => [:code, :description], :using => { :tsearch => { :prefix => true, :any_word => true } }

  has_many :products

  validates_presence_of :code, :description
  validates_uniqueness_of :code

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.is_service ||= false
  end

  def to_s
    "#{self.code} (#{self.gst_rate})"
  end

  def gst_rate
    self.tax_percentage ? "GST #{self.tax_percentage}%" : ' GST N/A'
  end
end