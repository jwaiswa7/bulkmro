class SalesQuoteRow < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanHaveTaxes

  belongs_to :lead_time_option, required: false
  belongs_to :sales_quote
  belongs_to :measurement_unit, required: false
  has_one :inquiry, :through => :sales_quote
  has_one :inquiry_currency, :through => :inquiry
  belongs_to :inquiry_product_supplier
  has_one :inquiry_product, :through => :inquiry_product_supplier
  has_one :product, :through => :inquiry_product
  has_one :supplier, :through => :inquiry_product_supplier

  attr_accessor :is_selected, :tax_percentage, :tax

  delegate :unit_cost_price, to: :inquiry_product_supplier, allow_nil: true
  delegate :sr_no, :legacy_id, to: :inquiry_product, allow_nil: true
  delegate :tax_percentage, :gst_rate, to: :tax_code, allow_nil: true
  # delegate :measurement_unit, :to => :product, allow_nil: true
  delegate :sku, :is_service, :is_kit?, :to => :product

  validates_uniqueness_of :inquiry_product_supplier, scope: :sales_quote
  validates_presence_of :quantity, :unit_selling_price
  validates_numericality_of :unit_selling_price, :greater_than_or_equal_to => 0
  validates_numericality_of :converted_unit_selling_price, :greater_than_or_equal_to => 0
  validates_numericality_of :quantity, :less_than_or_equal_to => :maximum_quantity, :if => :not_legacy?

  # validate :is_unit_selling_price_consistent_with_margin_percentage?, :if => :not_legacy?

  def is_unit_selling_price_consistent_with_margin_percentage?
    if unit_selling_price.round != calculated_unit_selling_price.round && Rails.env.development?
      errors.add :base, "selling price is not consistent with margin #{unit_selling_price} #{calculated_unit_selling_price} #{unit_cost_price_with_unit_freight_cost} #{margin_percentage} "
    end
  end

  validate :is_unit_selling_price_consistent_with_converted_unit_selling_price?, :if => :not_legacy?
  def is_unit_selling_price_consistent_with_converted_unit_selling_price?
    if converted_unit_selling_price.round != converted_unit_selling_price.round
      errors.add :base, 'selling price is not consistent with converted selling price'
    end
  end

  validate :is_unit_freight_cost_consistent_with_freight_cost_subtotal?, :if => :not_legacy?
  def is_unit_freight_cost_consistent_with_freight_cost_subtotal?
    if (freight_cost_subtotal / quantity).round != unit_freight_cost.round
      errors.add :base, 'freight cost is not consistent with freight cost subtotal'
    end
  end

  validate :tax_percentage_is_not_nil?, :if => :not_legacy?
  def tax_percentage_is_not_nil?
    if self.not_legacy? && self.tax_rate.tax_percentage.blank?
      errors.add :base, 'tax rate cannot be N/A'
    end
  end

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.margin_percentage ||= legacy? ? 0 : 15.0
    self.freight_cost_subtotal ||= 0.0
    self.unit_freight_cost ||= 0.0
    self.lead_time_option ||= LeadTimeOption.default
    self.measurement_unit ||= self.product.measurement_unit || MeasurementUnit.default

    if self.inquiry_product_supplier.present?
      self.quantity ||= maximum_quantity
      self.unit_selling_price ||= calculated_unit_selling_price
    end

    self.tax_code ||= product.best_tax_code
    self.tax_rate ||= product.best_tax_rate
  end

  def best_tax_code
    self.tax_code || self.product.best_tax_code
  end

  def best_tax_rate
    self.tax_rate || self.product.best_tax_rate
  end

  def applicable_tax_percentage
    if legacy_applicable_tax_percentage.present? && legacy_applicable_tax_percentage > 0
      legacy_applicable_tax_percentage / 100
    else
      if self.persisted? && self.inquiry.is_sez?
        0
      else
        self.best_tax_rate ? self.best_tax_rate.tax_percentage / 100.0 : 0
      end
    end
  end

  def conversion_rate
    self.sales_quote.inquiry_currency.conversion_rate || 1
  end

  def maximum_quantity
    self.inquiry_product.quantity if self.inquiry_product.present?
  end

  def total_tax
    total_selling_price_with_tax - total_selling_price
  end

  def total_selling_price
    self.unit_selling_price * self.quantity if self.unit_selling_price.present?
  end

  def total_selling_price_with_tax
    self.unit_selling_price_with_tax * self.quantity if self.unit_selling_price.present?
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
    if self.unit_cost_price_with_unit_freight_cost.present? && self.margin_percentage.present?
      if self.margin_percentage >= 100
        self.unit_selling_price
      else
        (self.unit_cost_price_with_unit_freight_cost / (1 - (self.margin_percentage / 100.0)))
      end
    end
  end

  def calculated_tax
    (self.calculated_unit_selling_price * (self.applicable_tax_percentage))
  end

  def calculated_unit_selling_price_with_tax
    (self.calculated_unit_selling_price + (self.calculated_unit_selling_price * (self.applicable_tax_percentage)))
  end

  def unit_selling_price_with_tax
    self.unit_selling_price + (self.unit_selling_price * (self.applicable_tax_percentage))
  end

  def calculated_converted_unit_selling_price
    (self.unit_selling_price / conversion_rate) if unit_selling_price.present?
  end

  def converted_total_selling_price
    (self.total_selling_price / conversion_rate) if unit_selling_price.present?
  end

  def converted_unit_cost_price_with_unit_freight_cost
    (self.unit_cost_price_with_unit_freight_cost / conversion_rate) if unit_cost_price_with_unit_freight_cost.present?
  end

  def converted_total_selling_price_with_tax
    (self.total_selling_price_with_tax / conversion_rate) if unit_selling_price.present?
  end

  def converted_total_tax
    (total_tax / conversion_rate)
  end

  def taxation
    service = Services::Overseers::SalesQuotes::Taxation.new(self)
    service.call
    service
  end

  def to_bp_catalog_s
    inquiry_product.to_bp_catalog_s
  end

  def to_s
    inquiry_product.to_s
  end

  def to_remote_s
    self.legacy_id.present? ? self.legacy_id : self.to_param
  end
end