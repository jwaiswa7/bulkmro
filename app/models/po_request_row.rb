class PoRequestRow < ApplicationRecord
  belongs_to :po_request
  belongs_to :sales_order_row
  has_one :sales_quote_row, :through => :sales_order_row
  has_one :inquiry_product_supplier, :through => :sales_quote_row
  has_one :inquiry_product, :through => :inquiry_product_supplier
  has_one :product, :through => :inquiry_product

  delegate :best_tax_code, :best_tax_rate, :measurement_unit, :converted_unit_selling_price, to: :sales_order_row, allow_nil: true

  attr_accessor :sr, :product_name, :brand, :lead_time_option

  enum status: {
      :'Draft' => 10,
      :'Po Requested' => 20
  }

  def total_selling_price
    if self.sales_quote_row.present?
      unit_selling_price = self.sales_quote_row.unit_selling_price
      unit_selling_price * self.quantity
    end
  end

  def converted_total_selling_price
    self.sales_quote_row.present? ? (self.total_selling_price / self.sales_quote_row.conversion_rate) : 0.0
  end
end