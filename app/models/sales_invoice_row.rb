class SalesInvoiceRow < ApplicationRecord
  belongs_to :sales_invoice

  def sku
    self.metadata['sku']
  end

  def quantity
    self.metadata['qty']
  end


  def hsn
    get_product.try(:best_tax_code).try(:chapter)
  end

  def mpn
    get_product.try(:product).try(:mpn)
  end

  def name
    get_product.try(:to_bp_catalog_s)
  end

  def uom
    get_product.try(:measurement_unit).try(:name) || get_product.try(:product).try(:measurement_unit).try(:name) || MeasurementUnit.default
  end

  def brand
    get_product.try(:product).brand.name if get_product.try(:product).try(:brand).present?
  end

  def tax_rate
    ((self.metadata['tax_amount'].to_f / self.metadata['row_total'].to_f) * 100).round(2)
  end

  private

  def get_product
    sales_invoice.sales_order.sales_quote.rows.joins(:product).where(products: {sku: self.sku}).first
  end

end
