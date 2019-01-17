class PoRequestRow < ApplicationRecord
  belongs_to :po_request
  belongs_to :sales_order_row
  has_one :sales_quote_row, :through => :sales_order_row
  has_one :inquiry_product_supplier, :through => :sales_quote_row
  has_one :inquiry_product, :through => :inquiry_product_supplier
  # has_one :product, :through => :inquiry_product

  belongs_to :product
  belongs_to :tax_code
  belongs_to :tax_rate
  belongs_to :measurement_unit, required: false

  accepts_nested_attributes_for :product

  delegate :measurement_unit, :converted_unit_selling_price, to: :sales_order_row, allow_nil: true

  attr_accessor :sr, :product_name, :brand, :lead_time_option

  enum status: {
      :'Draft' => 10,
      :'Po Requested' => 20
  }

  def total_selling_price
    if self.sales_quote_row.present?
      unit_selling_price = self.sales_quote_row.unit_selling_price
      if unit_selling_price.present?
        if self.quantity.present?
          unit_selling_price * self.quantity
        else
          unit_selling_price
        end
      end
    end
  end

  def total_selling_price_with_tax
    self.sales_quote_row.unit_selling_price_with_tax * self.quantity if self.sales_quote_row.present? && self.sales_quote_row.unit_selling_price.present?
  end

  def converted_total_selling_price
    self.sales_quote_row.present? ? (self.total_selling_price / self.sales_quote_row.conversion_rate) : 0.0
  end

  def field_disabled?
    self.sales_order_row.present?
  end
end