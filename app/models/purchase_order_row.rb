class PurchaseOrderRow < ApplicationRecord
  belongs_to :purchase_order

  def sku
    get_product.sku
  end

  def uom
    get_product.measurement_unit.name if get_product.measurement_unit.present?
  end

  def brand
    get_product.product.brand.name if get_product.product.brand.present?
  end

  def tax_rate
    get_product.tax_code.tax_percentage
  end

  def applicable_tax_percentage
    get_product.applicable_tax_percentage
  end

  def quantity
    self.metadata['PopQty'].to_f.round(2)
  end

  def unit_selling_price
    (self.metadata['PopPriceHt'].to_f).round(2) if self.metadata['PopPriceHt'].present?
  end

  def unit_selling_price_with_tax
    self.unit_selling_price + (self.unit_selling_price * (self.applicable_tax_percentage))
  end

  def total_tax
    total_selling_price_with_tax - total_selling_price
  end

  def total_selling_price
    (self.unit_selling_price * self.quantity).round(2) if self.metadata['PopPriceHt'].present?
  end

  def total_selling_price_with_tax
    self.unit_selling_price_with_tax * self.quantity if self.unit_selling_price.present?
  end

  # private
  def get_product
    purchase_order.inquiry.final_sales_quote.rows.select { | supplier_row |  supplier_row.product.id == self.metadata['PopProductId'].to_i || supplier_row.product.legacy_id  == self.metadata['PopProductId'].to_i}.first
  end

end
