class InquiryProductSupplier < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasSupplier

  belongs_to :inquiry_product
  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id
  has_one :product, through: :inquiry_product
  has_one :inquiry, through: :inquiry_product
  has_many :sales_quote_rows, dependent: :destroy
  has_one :final_sales_quote, through: :inquiry, class_name: 'SalesQuote'
  has_one :final_sales_quote_row, -> (record) { where(inquiry_product_supplier_id: record.id) }, through: :final_sales_quote, class_name: 'SalesQuoteRow', source: :rows
  belongs_to :supplier_rfq, required: false
  delegate :sr_no, to: :inquiry_product
  has_many :supplier_rfq_revisions
  has_many :supplier_products, through: :supplier

  validates_uniqueness_of :supplier, scope: :inquiry_product
  validates_numericality_of :unit_cost_price, greater_than_or_equal_to: 0

  attr_accessor :quantity

  after_initialize :set_defaults, if: :new_record?
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

  def unit_cost_price_with_freight
    (self.unit_cost_price || 0.0) + (self.unit_freight || 0.0)
  end

  def total_unit_cost_price_with_freight
    self.unit_cost_price_with_freight.present? ? (unit_cost_price_with_freight * (self.inquiry_product.quantity)) : 0.0
  end

  def unit_cost_price_with_freight_with_tax
    (unit_cost_price_with_freight || 0.0) + ((self.gst.present? && self.gst > 0.0) ? (unit_cost_price * self.gst) / 100.0 : 0.0)
  end

  def total_unit_cost_price_with_freight_with_tax
    unit_cost_price_with_freight_with_tax * (self.inquiry_product.quantity) if unit_cost_price_with_freight_with_tax.present?
  end
end
