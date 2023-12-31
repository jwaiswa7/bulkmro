class SalesInvoiceRow < ApplicationRecord
  belongs_to :sales_invoice
  has_many :packing_slip_rows

  def sku
    self.metadata['sku']
  end

  def quantity
    self.metadata['qty']
  end

  def get_remaining_quantity
    self.metadata['qty'] - self.packing_slip_rows.sum(&:delivery_quantity)
  end


  def hsn
    get_product.try(:best_tax_code).try(:chapter)
  end

  def tax_code_six_digits
    get_product.try(:best_tax_code).to_s[0..5]
  end

  def mpn
    get_product.try(:product).try(:mpn) || get_product.try(:mpn)
  end

  def name
    get_product.try(:to_bp_catalog_s) || get_product.try(:name)
  end

  def description
    self.metadata['description']
  end

  def uom
    get_product.try(:measurement_unit).try(:name) || get_product.try(:product).try(:measurement_unit).try(:name) || MeasurementUnit.default
  end

  def sales_order_row
    product = Product.where(sku: self.sku).last
    if product.present?
      sales_invoice.sales_order.rows.where(product_id: product.id).last
    end
  end

  def brand
    get_product.try(:product).try(:brand).try(:name) || get_product.try(:brand).try(:name)
  end

  def tax_rate
    tax_amount = self.metadata['tax_amount'].to_f
    row_total = self.metadata['row_total'].to_f
    if(tax_amount.nil? || tax_amount.zero?) || (row_total.nil? || row_total.zero?)
      0
    else
      ((tax_amount / row_total) * 100)
    end
  end

  def freight_cost_subtotal
    sales_quote_rows = self.sales_invoice.sales_order.sales_quote.rows.select {|row| row.product.sku == self.sku }
    sales_quote_rows.present? ? sales_quote_rows.first.freight_cost_subtotal : 0
  end

  def get_product_details
    Product.find_by_sku(self.sku)
  end

  private

    def get_product
      sales_invoice.sales_order.sales_quote.rows.joins(:product).where(products: { sku: self.sku }).first || Product.find_by_sku(self.sku)
    end
end
