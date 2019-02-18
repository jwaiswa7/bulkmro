# frozen_string_literal: true

class PurchaseOrderRow < ApplicationRecord
  belongs_to :purchase_order

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
    metadata['PopTaxRate'].gsub(/\D/, '').to_f
  end

  def applicable_tax_percentage
    metadata['PopTaxRate'].gsub(/\D/, '').to_f / 100
  end

  def quantity
    metadata['PopQty'].to_f.round(2)
  end

  def unit_selling_price
    metadata['PopPriceHt'].to_f.round(2) if metadata['PopPriceHt'].present?
  end

  def unit_selling_price_with_tax
    unit_selling_price + (unit_selling_price * (applicable_tax_percentage || 0))
  end

  def total_tax
    total_selling_price_with_tax - total_selling_price
  end

  def total_selling_price
    (unit_selling_price * quantity).round(2) if metadata['PopPriceHt'].present?
  end

  def total_selling_price_with_tax
    unit_selling_price_with_tax * quantity if unit_selling_price.present?
  end

  private

    def get_product
      Product.find_by_legacy_id(metadata['PopProductId'].to_i) || Product.find(metadata['PopProductId'])
    end
end
