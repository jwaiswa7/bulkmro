# frozen_string_literal: true

class SalesInvoiceRow < ApplicationRecord
  belongs_to :sales_invoice

  def sku
    metadata['sku']
  end

  def quantity
    metadata['qty']
  end

  def hsn
    get_product.try(:best_tax_code).try(:chapter)
  end

  def mpn
    get_product.try(:product).try(:mpn) || get_product.try(:mpn)
  end

  def name
    get_product.try(:to_bp_catalog_s) || get_product.try(:name)
  end

  def uom
    get_product.try(:measurement_unit).try(:name) || get_product.try(:product).try(:measurement_unit).try(:name) || MeasurementUnit.default
  end

  def brand
    get_product.try(:product).try(:brand).try(:name) || get_product.try(:brand).try(:name)
  end

  def tax_rate
    ((metadata['tax_amount'].to_f / metadata['row_total'].to_f) * 100).round(2)
  end

  private

    def get_product
      sales_invoice.sales_order.sales_quote.rows.joins(:product).where(products: { sku: sku }).first || Product.find_by_sku(sku)
    end
end
