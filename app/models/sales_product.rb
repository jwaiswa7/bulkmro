class SalesProduct < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasSupplier

  belongs_to :sales_quote
  belongs_to :inquiry_supplier
  has_one :inquiry_product, :through => :inquiry_supplier
  has_one :product, :through => :inquiry_product

  delegate :unit_cost_price, to: :inquiry_supplier

  validates_uniqueness_of :product, scope: :sales_quote
  validates_presence_of :quantity, :unit_selling_price
  validates_numericality_of :quantity, :greater_than_or_equal_to => 1
  validates_numericality_of :unit_selling_price, :greater_than => 0

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.quantity ||= 1
    self.margin_percentage ||= 15.0
    self.unit_selling_price || 0.0
  end
end