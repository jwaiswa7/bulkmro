class SalesProduct < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_quote
  belongs_to :inquiry_supplier
  has_one :inquiry_product, :through => :inquiry_supplier
  has_one :product, :through => :inquiry_product

  delegate :unit_cost_price, to: :inquiry_supplier, allow_nil: true

  validates_uniqueness_of :inquiry_supplier, scope: :sales_quote
  validates_presence_of :quantity, :unit_selling_price
  validates_numericality_of :quantity, :greater_than_or_equal_to => 1
  validates_numericality_of :unit_selling_price, :greater_than => 0
  validates_numericality_of :quantity, :less_than_or_equal_to => :maximum_quantity

  validate :is_unit_selling_price_consistent_with_margin_percentage?
  def is_unit_selling_price_consistent_with_margin_percentage?
    if unit_selling_price.round(2) != calculated_unit_selling_price.round(2)
      errors.add :base, 'selling price is not consistent with margin'
    end
  end

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.margin_percentage ||= 15.0

    if self.inquiry_supplier.present?
      self.quantity ||= maximum_quantity
      self.unit_selling_price ||= calculated_unit_selling_price
    end
  end

  def maximum_quantity
    self.inquiry_product.quantity
  end

  def calculated_unit_selling_price
    (self.unit_cost_price / (1 - (self.margin_percentage / 100))).round(2)
  end
end