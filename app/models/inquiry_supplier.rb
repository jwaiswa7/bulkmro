class InquirySupplier < ApplicationRecord
  include Mixins::HasSupplier

  belongs_to :inquiry_product
  has_one :product, :through => :inquiry_product
  has_one :inquiry, :through => :inquiry_product

  attr_accessor :lowest_price, :latest_price

  validates_uniqueness_of :supplier, scope: :inquiry_product
  validates_numericality_of :unit_cost_price, :greater_than_or_equal_to => 0

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.unit_cost_price ||= 0
  end
end
