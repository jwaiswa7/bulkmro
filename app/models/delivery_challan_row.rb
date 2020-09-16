class DeliveryChallanRow < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasConvertedCalculations
  belongs_to :delivery_challan
  belongs_to :inquiry_product
  belongs_to :product
  belongs_to :sales_order_row, required: false
  delegate :sales_quote_row, to: :sales_order_row, allow_nil: true
  
  validates_numericality_of :quantity, greater_than: 0, allow_nil: true

  def total_selling_price
    sales_quote_row.unit_selling_price * self.quantity if sales_quote_row.present? && sales_quote_row.unit_selling_price.present?
  end

  def converted_unit_selling_price
    sales_quote_row.present? && sales_quote_row.conversion_rate.present? ? (sales_quote_row.unit_selling_price / self.sales_quote_row.conversion_rate) : self&.sales_quote_row&.unit_selling_price
  end

  def converted_total_selling_price
    sales_quote_row.present? && sales_quote_row.conversion_rate.present? ? (self.total_selling_price / sales_quote_row.conversion_rate) : self.total_selling_price
  end

  def unit_selling_price_with_tax
    sales_quote_row.unit_selling_price + (sales_quote_row.unit_selling_price * sales_quote_row.applicable_tax_percentage) if sales_quote_row.present?
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

end