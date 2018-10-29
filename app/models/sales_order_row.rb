class SalesOrderRow < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_order
  has_one :sales_quote, :through => :sales_order
  belongs_to :sales_quote_row
  has_one :tax_code, :through => :sales_quote_row
  has_one :inquiry_product, :through => :sales_quote_row
  has_one :product, :through => :inquiry_product

  delegate :unit_cost_price_with_unit_freight_cost, :unit_selling_price, :converted_unit_selling_price, :margin_percentage, :unit_freight_cost, :freight_cost_subtotal, :converted_unit_cost_price_with_unit_freight_cost, :converted_unit_selling_price, :converted_converted_unit_selling_price, :converted_margin_percentage, :converted_unit_freight_cost, :converted_freight_cost_subtotal, to: :sales_quote_row, allow_nil: true
  delegate :sr_no, to: :inquiry_product, allow_nil: true
  delegate :taxation, to: :sales_quote_row
  delegate :is_service, :to => :sales_quote_row
  delegate :measurement_unit, :to => :sales_quote_row, allow_nil: true
  delegate :remote_uid, :to => :sales_quote_row
  delegate :best_tax_code, :to => :sales_quote_row, allow_nil: true
  delegate :best_tax_rate, :to => :sales_quote_row, allow_nil: true
  attr_accessor :tax_percentage

  validates_presence_of :quantity
  validates_numericality_of :quantity, :less_than_or_equal_to => :maximum_quantity, :greater_than => 0
  validates_uniqueness_of :sales_quote_row_id, scope: :sales_order_id

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    if self.sales_quote_row.present?
      self.quantity ||= maximum_quantity
    end
  end

  def maximum_quantity
    self.sales_quote_row.quantity if sales_quote_row.present?
  end

  def calculated_unit_selling_price
    (self.sales_quote_row.unit_cost_price / (1 - (self.sales_quote_row.margin_percentage / 100.0))).round(2) if self.sales_quote_row.unit_cost_price.present? && self.sales_quote_row if self.sales_quote_row.present?.margin_percentage.present? if self.sales_quote_row.present?
  end

  def calculated_unit_selling_price_with_tax
    self.sales_quote_row.calculated_unit_selling_price + (self.sales_quote_row.calculated_unit_selling_price * (self.sales_quote_row.applicable_tax_percentage)).round(2) if self.sales_quote_row.present?
  end

  def unit_selling_price_with_tax
    self.sales_quote_row.unit_selling_price + (self.sales_quote_row.unit_selling_price * (self.sales_quote_row.applicable_tax_percentage)).round(2) if self.sales_quote_row.present?
  end

  def converted_total_selling_price
    (self.total_selling_price / sales_quote_row.conversion_rate).round(2)
  end

  def converted_total_selling_price_with_tax
    (self.total_selling_price_with_tax / sales_quote_row.conversion_rate).round(2)
  end

  def calculated_tax
    (self.sales_quote_row.unit_selling_price * (self.sales_quote_row.applicable_tax_percentage)).round(2) if self.sales_quote_row.present?
  end

  def total_selling_price_with_tax
    self.sales_quote_row.unit_selling_price_with_tax * self.quantity if self.sales_quote_row.present? && self.sales_quote_row.unit_selling_price.present?
  end

  def total_tax
    total_selling_price_with_tax - total_selling_price
  end

  def total_selling_price
    self.sales_quote_row.unit_selling_price * self.quantity if self.sales_quote_row.unit_selling_price.present? if self.sales_quote_row.present?
  end

  def total_margin
    self.sales_quote_row.total_selling_price - self.sales_quote_row.total_cost_price if self.sales_quote_row.present?
  end

  def total_cost_price
    self.sales_quote_row.unit_cost_price * self.quantity if self.sales_quote_row.present?
  end

  def hsn_or_sac
    if is_service
      :sac
    else
      :hsn
    end
  end
  def to_remote_s
    self.to_param
  end
end
