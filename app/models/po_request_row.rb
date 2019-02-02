class PoRequestRow < ApplicationRecord
  belongs_to :po_request
  belongs_to :sales_order_row, required: false
  has_one :sales_quote_row, :through => :sales_order_row
  has_one :inquiry_product_supplier, :through => :sales_quote_row
  has_one :inquiry_product, :through => :inquiry_product_supplier
  # has_one :product, :through => :inquiry_product

  # has_one :product, :through => :sales_order_row

  belongs_to :product, required: false
  belongs_to :tax_code, required: false
  belongs_to :tax_rate, required: false
  belongs_to :measurement_unit, required: false

  accepts_nested_attributes_for :product

  delegate :measurement_unit, to: :sales_order_row, allow_nil: true
  attr_accessor :sr, :product_name, :brand, :lead_time_option

  enum status: {
      :'Draft' => 10,
      :'Po Requested' => 20
  }

  def total_selling_price
    if self.sales_quote_row.present?
      unit_selling_price = self.unit_selling_price
      if unit_selling_price.present?
        if self.quantity.present?
          unit_selling_price * self.quantity
        else
          unit_selling_price
        end
      end
    else
      if self.quantity.present?
        self.product_unit_selling_price * self.quantity
      else
        self.product_unit_selling_price
      end
    end
  end

  def unit_selling_price
    self.sales_quote_row.unit_cost_price if self.sales_quote_row.present?
  end

  def converted_unit_selling_price
    self.sales_quote_row.present? ? (self.unit_selling_price / self.sales_quote_row.conversion_rate) : ((self.product_unit_selling_price / self.conversion) if !self.conversion.nil?)
  end

  def unit_selling_price_with_tax
    if self.unit_selling_price.present?
      return self.unit_selling_price + (self.unit_selling_price * ((self.tax_rate.tax_percentage / 100) || 0)) if self.tax_rate.present?
    elsif self.product_unit_selling_price.present?
      return self.product_unit_selling_price + (self.product_unit_selling_price * ((self.tax_rate.tax_percentage / 100) || 0)) if self.tax_rate.present?
    end
    return 0
  end

  def converted_total_selling_price
    if self.sales_quote_row.present?
      (self.total_selling_price / self.sales_quote_row.conversion_rate)
    else
       if self.conversion.nil?
         0.0
         else
         (self.total_selling_price / self.conversion)
       end
    end
  end

  def total_selling_price_with_tax
    self.quantity ? self.unit_selling_price_with_tax * self.quantity : 0
  end

  def converted_total_selling_price_with_tax
    if self.sales_quote_row.present?
      (self.total_selling_price_with_tax / sales_quote_row.conversion_rate)
    else
      if self.conversion.nil?
        0.0
      else
        (self.total_selling_price_with_tax / self.conversion)
      end
    end
  end

  def total_tax
    total_selling_price.present? ? (total_selling_price_with_tax - total_selling_price) : 0.0
  end

  def converted_total_tax
    converted_total_selling_price.present? ? converted_total_selling_price_with_tax - converted_total_selling_price : 0.0
  end

  def total_buying_price
    if self.quantity
      self.sales_order_row.present? && self.sales_order_row.unit_selling_price.present? ? self.sales_order_row.unit_selling_price * self.quantity : 0.0
    else
      0.0
    end
  end

  def converted_total_buying_price
    sales_quote_row.present? ? (self.total_buying_price / sales_quote_row.conversion_rate) : 0.0
  end

  def field_disabled?
    self.sales_order_row.present?
  end
end