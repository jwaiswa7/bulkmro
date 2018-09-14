class SalesQuoteRow < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_quote
  has_one :inquiry, :through => :sales_quote
  has_one :inquiry_currency, :through => :inquiry
  belongs_to :inquiry_product_supplier
  has_one :inquiry_product, :through => :inquiry_product_supplier
  has_one :product, :through => :inquiry_product
  has_one :supplier, :through => :inquiry_product_supplier

  delegate :unit_cost_price, to: :inquiry_product_supplier, allow_nil: true
  delegate :sr_no, to: :inquiry_product, allow_nil: true

  validates_uniqueness_of :inquiry_product_supplier, scope: :sales_quote
  validates_presence_of :quantity, :unit_selling_price
  validates_numericality_of :quantity, :greater_than_or_equal_to => 1
  validates_numericality_of :unit_selling_price, :greater_than => 0
  validates_numericality_of :converted_unit_selling_price, :greater_than => 0
  validates_numericality_of :quantity, :less_than_or_equal_to => :maximum_quantity

  validate :is_unit_selling_price_consistent_with_margin_percentage?
  def is_unit_selling_price_consistent_with_margin_percentage?
    if unit_selling_price.round != calculated_unit_selling_price.round
      errors.add :base, 'selling price is not consistent with margin'
    end
  end

  validate :is_unit_selling_price_consistent_with_converted_unit_selling_price?
  def is_unit_selling_price_consistent_with_converted_unit_selling_price?
    if converted_unit_selling_price.round != calculated_converted_unit_selling_price.round
      errors.add :base, 'selling price is not consistent with converted selling price'
    end
  end

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.margin_percentage ||= 15.0

    if self.inquiry_product_supplier.present?
      self.quantity ||= maximum_quantity
      self.unit_selling_price ||= calculated_unit_selling_price
    end
  end

  def maximum_quantity
    self.inquiry_product.quantity if self.inquiry_product.present?
  end

  def calculated_unit_selling_price
    (self.unit_cost_price / (1 - (self.margin_percentage / 100))).round(2)
  end

  def calculated_converted_unit_selling_price
    (self.unit_selling_price / conversion_rate).round(2) if unit_selling_price.present?
  end

  def conversion_rate
    self.sales_quote.inquiry_currency.conversion_rate
  end

  def to_s
    product.to_s
  end
end