class SalesQuoteRow < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :lead_time_option, required: false
  belongs_to :sales_quote
  has_one :inquiry, :through => :sales_quote
  has_one :inquiry_currency, :through => :inquiry
  belongs_to :inquiry_product_supplier
  belongs_to :tax_code
  has_one :inquiry_product, :through => :inquiry_product_supplier
  has_one :product, :through => :inquiry_product
  has_one :supplier, :through => :inquiry_product_supplier

  attr_accessor :is_selected, :tax_percentage, :tax

  delegate :unit_cost_price, to: :inquiry_product_supplier, allow_nil: true
  delegate :sr_no, to: :inquiry_product, allow_nil: true
  delegate :tax_percentage, :gst_rate, to: :tax_code, allow_nil: true
  delegate :is_service, :to => :product

  validates_uniqueness_of :inquiry_product_supplier, scope: :sales_quote
  validates_presence_of :quantity, :unit_selling_price
  validates_numericality_of :quantity, :greater_than_or_equal_to => 1
  validates_numericality_of :unit_selling_price, :greater_than => 0
  validates_numericality_of :converted_unit_selling_price, :greater_than => 0
  validates_numericality_of :quantity, :less_than_or_equal_to => :maximum_quantity

  validate :is_unit_selling_price_consistent_with_margin_percentage?
  def is_unit_selling_price_consistent_with_margin_percentage?
    if unit_selling_price.floor != calculated_unit_selling_price.floor
      errors.add :base, 'selling price is not consistent with margin'
    end
  end

  validate :is_unit_selling_price_consistent_with_converted_unit_selling_price?
  def is_unit_selling_price_consistent_with_converted_unit_selling_price?
    if converted_unit_selling_price.floor != calculated_converted_unit_selling_price.floor
      errors.add :base, 'selling price is not consistent with converted selling price'
    end
  end

  validate :is_unit_freight_cost_consistent_with_freight_cost_subtotal?
  def is_unit_freight_cost_consistent_with_freight_cost_subtotal?
    if (freight_cost_subtotal / quantity).floor != unit_freight_cost.floor
      errors.add :base, 'freight cost is not consistent with freight cost subtotal'
    end
  end

  validate :tax_percentage_is_not_nil?
  def tax_percentage_is_not_nil?
    if self.tax_code.tax_percentage.blank?
      errors.add :base, 'tax rate cannot be N/A'
    end
  end

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.margin_percentage ||= 15.0
    self.freight_cost_subtotal ||= 0.0
    self.unit_freight_cost ||= 0.0
    self.lead_time_option ||= LeadTimeOption.default

    if self.inquiry_product_supplier.present?
      self.quantity ||= maximum_quantity
      self.unit_selling_price ||= calculated_unit_selling_price
    end
  end

  def best_tax_code
    self.tax_code || self.product.best_tax_code
  end

  def applicable_tax_percentage
    self.best_tax_code ? self.best_tax_code.tax_percentage / 100.0 : 0
  end

  def conversion_rate
    self.sales_quote.inquiry_currency.conversion_rate
  end

  def maximum_quantity
    self.inquiry_product.quantity if self.inquiry_product.present?
  end

  def total_tax
    self.calculated_tax * self.quantity
  end

  def total_selling_price
    self.calculated_unit_selling_price * self.quantity if self.calculated_unit_selling_price.present?
  end

  def total_selling_price_with_tax
    (self.calculated_unit_selling_price + self.calculated_tax) * self.quantity if self.calculated_unit_selling_price.present?
  end

  def total_margin
    self.total_selling_price - self.total_cost_price
  end

  def total_cost_price
    self.unit_cost_price * self.quantity
  end

  def unit_cost_price_with_unit_freight_cost
    unit_cost_price + unit_freight_cost if unit_cost_price.present? && unit_freight_cost.present?
  end

  def calculated_unit_selling_price
    (self.unit_cost_price_with_unit_freight_cost / (1 - (self.margin_percentage / 100.0))).floor(2) if self.unit_cost_price.present? && self.margin_percentage.present?
  end

  def calculated_tax
    (self.calculated_unit_selling_price * (self.applicable_tax_percentage)).floor(2)
  end

  def calculated_unit_selling_price_with_tax
    self.calculated_unit_selling_price + (self.calculated_unit_selling_price * (self.applicable_tax_percentage)).floor(2)
  end

  def calculated_converted_unit_selling_price
    (self.unit_selling_price / conversion_rate).floor(2) if unit_selling_price.present?
  end

  def taxation
    service = Services::Overseers::SalesQuotes::Taxation.new(self)
    service.call
    service
  end

  def to_s
    product.to_s
  end
end