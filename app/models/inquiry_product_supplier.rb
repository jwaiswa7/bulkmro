class InquiryProductSupplier < ApplicationRecord
  include Mixins::HasSupplier

  belongs_to :inquiry_product
  has_one :product, :through => :inquiry_product
  has_one :inquiry, :through => :inquiry_product
  has_many :sales_quote_rows, dependent: :destroy

  delegate :sr_no, to: :inquiry_product

  validates_uniqueness_of :supplier, scope: :inquiry_product
  validates_numericality_of :unit_cost_price, :greater_than_or_equal_to => 0

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.unit_cost_price ||= 0
  end

  def lowest_unit_cost_price
    self.product.lowest_unit_cost_price_for(self.supplier, self) if self.persisted?
  end

  def latest_unit_cost_price
    self.product.latest_unit_cost_price_for(self.supplier, self) if self.persisted?
  end

  def to_s
    self.supplier
  end
end
