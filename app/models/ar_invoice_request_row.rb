class ArInvoiceRequestRow < ApplicationRecord
  belongs_to :ar_invoice_request, class_name: 'ArInvoiceRequest'
  belongs_to :sales_order, class_name: 'SalesOrder'
  belongs_to :sales_order_row, class_name: 'SalesOrderRow'
  belongs_to :inward_dispatch_row, class_name: 'InwardDispatchRow'
  belongs_to :product, class_name: 'Product'
  has_many :packing_slip_rows
  validates_numericality_of :delivered_quantity, greater_than: 0, allow_nil: true
  validate :is_delivered_quantity_less
  delegate :converted_unit_selling_price, to: :sales_order_row, allow_nil: true
  delegate :best_tax_code, to: :sales_order_row, allow_nil: true
  delegate :best_tax_rate, to: :sales_order_row, allow_nil: true
  delegate :unit_selling_price, to: :sales_order_row, allow_nil: true
  delegate :unit_selling_price_with_tax, to: :sales_order_row, allow_nil: true

  def is_delivered_quantity_less
    errors.add(:delivered_quantity, 'must be less than Existing Quantity ') if delivered_quantity > quantity
  end

  def to_s
    self.inward_dispatch_row.to_s
  end

  def conversion_rate
    self.sales_order.inquiry_currency.conversion_rate || 1
  end

  def get_remaining_quantity
    self.delivered_quantity - self.packing_slip_rows.sum(&:delivery_quantity)
  end

  def tax_rate
    self.best_tax_rate.tax_percentage
  end

  def total_selling_price_with_tax
    self.unit_selling_price_with_tax * self.delivered_quantity if self.delivered_quantity && sales_order_row.present? && sales_order_row.unit_selling_price_with_tax.present?
  end

  def total_selling_price
    self.unit_selling_price * self.delivered_quantity if self.delivered_quantity && sales_order_row.present? && sales_order_row.unit_selling_price.present?
  end

  def total_tax
    total_selling_price_with_tax - total_selling_price
  end

  def converted_total_selling_price
    (self.total_selling_price / conversion_rate) if unit_selling_price.present?
  end

  def converted_total_selling_price_with_tax
    (self.total_selling_price_with_tax / conversion_rate) if unit_selling_price.present?
  end


end
