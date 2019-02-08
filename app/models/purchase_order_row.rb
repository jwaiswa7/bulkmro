# frozen_string_literal: true

class PurchaseOrderRow < ApplicationRecord
  belongs_to :purchase_order

  after_create :increase_product_count
  before_destroy :decrease_product_count


  def increase_product_count
    product = self.get_product
    product.update_attribute("total_pos", product.total_pos + 1) if product.present?
  end

  def decrease_product_count
    product = self.get_product
    product.update_attribute("total_pos", (product.total_pos == 0 ? 0 : (product.total_pos - 1))) if product.present?
  end

  def sku
    get_product.sku if get_product.present?
  end

  def uom
    get_product.measurement_unit.name if get_product.present? && get_product.measurement_unit.present?
  end

  def brand
    get_product.brand.name if get_product.present? && get_product.brand.present?
  end

  def tax_rate
    self.metadata["PopTaxRate"].gsub(/\D/, "").to_f
  end

  def applicable_tax_percentage
    self.metadata["PopTaxRate"].gsub(/\D/, "").to_f / 100
  end

  def quantity
    self.metadata["PopQty"].to_f.round(2)
  end

  def unit_selling_price
    (self.metadata["PopPriceHt"].to_f).round(2) if self.metadata["PopPriceHt"].present?
  end

  def unit_selling_price_with_tax
    self.unit_selling_price + (self.unit_selling_price * (self.applicable_tax_percentage || 0))
  end

  def total_tax
    total_selling_price_with_tax - total_selling_price
  end

  def total_selling_price
    (self.unit_selling_price.to_f * self.quantity.to_f).round(2) if self.metadata["PopPriceHt"].present?
  end

  def total_selling_price_with_tax
    self.unit_selling_price_with_tax * self.quantity if self.unit_selling_price.present?
  end

  def get_product
    Product.where(legacy_id: self.metadata["PopProductId"].to_i).or(Product.where(id: Product.decode_id(self.metadata["PopProductId"]))).try(:first)
  end
end
