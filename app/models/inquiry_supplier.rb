class InquirySupplier < ApplicationRecord
  belongs_to :inquiry_product
  has_one :product, :through => :inquiry_product
  has_one :inquiry, :through => :inquiry_product
  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id

  validates_uniqueness_of :supplier, scope: :inquiry_product
  validates_numericality_of :unit_price, :greater_than_or_equal_to => 0

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.unit_price ||= 0
  end
end
