class SalesInvoiceRow < ApplicationRecord
  belongs_to :sales_invoice

  def sku
    self.metadata['sku']
  end

  def quantity
    self.metadata['qty']
  end

  def hsn
    get_product.tax_code.chapter
  end

  def name
    get_product.to_bp_catalog_s
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

  private
  def get_product
    sales_invoice.sales_order.sales_quote.rows.select { | supplier_row | supplier_row.product.sku == self.sku}.first
  end

end
