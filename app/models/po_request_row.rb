# frozen_string_literal: true

class PoRequestRow < ApplicationRecord
  belongs_to :po_request
  belongs_to :sales_order_row, required: false
  has_one :sales_quote_row, through: :sales_order_row
  has_one :inquiry_product_supplier, through: :sales_quote_row
  has_one :inquiry_product, through: :inquiry_product_supplier
  has_one :purchase_order_row
  # has_one :product, through: :inquiry_product

  validates :lead_time, not_in_past: true
  validate :valid_lead_time

  # has_one :product, :through => :sales_order_row

  belongs_to :product, validate: false
  belongs_to :tax_code, required: false
  belongs_to :tax_rate, required: false
  belongs_to :measurement_unit, required: false
  belongs_to :brand, required: false

  accepts_nested_attributes_for :product

  # delegate :measurement_unit, to: :sales_order_row, allow_nil: true
  attr_accessor :sr, :product_name, :lead_time_option

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.measurement_unit ||= MeasurementUnit.default
    self.product ||= sales_order_row.product if sales_order_row.present?
  end

  enum status: {
      'Draft': 10,
      'Po Requested': 20
  }

  def total_buying_price
    if unit_selling_price.present?
      if self.quantity.present?
        unit_selling_price * self.quantity
      else
        unit_selling_price
      end
    end
  end

  def total_price_with_selected_currency
    if self.selected_currency_up.present?
      if self.quantity.present?
        self.selected_currency_up * self.quantity
      else
        self.selected_currency_up
      end
    end
  end

  def unit_price_per_quantity
    self.quantity.present? ? ((self.converted_total_selling_price || 0) / self.quantity) : 0
  end

  def unit_selling_price
    if self.unit_price.present?
      self.unit_price
    else
      self.sales_quote_row.present? ? sales_quote_row.unit_cost_price : 0.0
    end
  end

  def converted_unit_selling_price
    sales_quote_row.present? && sales_quote_row.conversion_rate.present? ? (self.unit_selling_price / self.sales_quote_row.conversion_rate) : self.unit_selling_price
  end

  def unit_selling_price_with_tax
    return self.unit_selling_price + (self.unit_selling_price * ((self.tax_rate.tax_percentage / 100) || 0)) if self.tax_rate.present?
    0
  end

  def unit_selling_price_with_discount
    return self.unit_selling_price - (100 - self.discount_percentage)/100 if self.discount_percentage.present? && self.discount_percentage > 0.0
    self.unit_selling_price
  end

  def converted_total_selling_price
    sales_quote_row.present? && sales_quote_row.conversion_rate.present? ? (self.total_selling_price / sales_quote_row.conversion_rate) : self.total_selling_price
  end

  def total_selling_price_with_tax
    self.quantity ? self.unit_selling_price_with_tax * self.quantity : 0
  end

  def converted_total_selling_price_with_tax
    sales_quote_row.present? && sales_quote_row.conversion_rate.present? ? (self.total_selling_price_with_tax / sales_quote_row.conversion_rate) : self.total_selling_price_with_tax
  end

  def total_tax
    total_selling_price_with_tax - total_selling_price
  end

  def converted_total_tax
    converted_total_selling_price_with_tax - converted_total_selling_price
  end

  def total_selling_price
    if self.quantity
      self.sales_order_row.present? && self.sales_order_row.unit_selling_price.present? ? self.sales_order_row.unit_selling_price * self.quantity : 0.0
    else
      0.0
    end
  end

  def subtotal
    self.unit_selling_price_with_discount * self.quantity
  end

  def tax_value
    self.subtotal * self.tax_rate.tax_percentage / 100
  end

  def total_incl_tax
    self.subtotal + self.tax_value
  end

  def converted_total_buying_price
    self.total_buying_price.present? && sales_quote_row.present? ? (self.total_buying_price / sales_quote_row.conversion_rate) : 0.0
  end

  def field_disabled?
    self.sales_order_row.present?
  end

  def is_inquiry_product_supplier_present?
    self.inquiry_product_supplier.present?
  end

  def supplier_product_name
    if is_inquiry_product_supplier_present?
      self.inquiry_product_supplier.bp_catalog_name.present? ? self.inquiry_product_supplier.bp_catalog_name : self.inquiry_product_supplier.product.name
    end
  end

  def supplier_product_sku
    if is_inquiry_product_supplier_present?
      self.inquiry_product_supplier.bp_catalog_sku.present? ? self.inquiry_product_supplier.bp_catalog_sku : self.inquiry_product_supplier.product.sku
    end
  end

  def to_s
    if supplier_product_name.present? && supplier_product_sku.present?
      "#{supplier_product_sku} - #{supplier_product_name}"
    elsif self.product.present?
      product = self.product
      "#{product.sku} - #{product.name}"
    end
  end

  def taxation
    service = Services::Overseers::PoRequests::Taxation.new(self)
    service.call
    service
  end

  def best_tax_code
    self.tax_code || self.product.best_tax_code
  end

  def best_tax_rate
    self.tax_rate || self.product.best_tax_rate
  end

  def has_sales_order_row?
    self.sales_order_row.present?
  end

  private

  def valid_lead_time
    errors.add(:lead_time, 'is before tomorrow') if lead_time && lead_time < (Date.today + 1.day)
  end
end
