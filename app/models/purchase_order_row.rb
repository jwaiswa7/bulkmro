class PurchaseOrderRow < ApplicationRecord
  belongs_to :purchase_order
  has_many :inward_dispatch_rows
  belongs_to :product, optional: true

  after_create :increase_product_count
  before_destroy :decrease_product_count


  def increase_product_count
    product = self.get_product
    product.update_attribute('total_pos', product.total_pos + 1) if product.present?
  end

  def decrease_product_count
    product = self.get_product
    product.update_attribute('total_pos', (product.total_pos == 0 ? 0 : (product.total_pos - 1))) if product.present?
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
    if self.metadata['PopTaxRate'] == 'IMP@18'
      0.0
    else
      self.metadata['PopTaxRate'].gsub(/\D/, '').to_f
    end
  end

  def applicable_tax_percentage
    self.metadata['PopTaxRate'].gsub(/\D/, '').to_f / 100 if !(self.metadata['PopTaxRate'].include?('IMP'))
  end

  def quantity
    self.metadata['PopQty'].to_f.round(2)
  end

  def unit_selling_price
    price = if self.metadata['PopPriceHtBase'].present?
              (self.metadata['PopPriceHtBase'].to_f * self.purchase_order.metadata['PoCurrencyChangeRate'].to_f).round(2)
            else
              (self.metadata['PopPriceHt'].to_f * self.purchase_order.metadata['PoCurrencyChangeRate'].to_f).round(2) if self.metadata['PopPriceHt'].present?
            end
    self.metadata['PopDiscount'].present? ? ((1 - (self.metadata['PopDiscount'].to_f / 100)) * price).round(2) : price
  end

  def unit_selling_price_with_tax
    self.unit_selling_price + (self.unit_selling_price * (self.applicable_tax_percentage || 0))
  end

  def total_tax
    total_selling_price_with_tax - total_selling_price
  end

  def total_selling_price
    (self.unit_selling_price.to_f * self.quantity.to_f).round(2) if self.metadata['PopPriceHt'].present?
  end

  def total_selling_price_with_tax
    self.unit_selling_price_with_tax * self.quantity if self.unit_selling_price.present?
  end

  def get_product
    Product.where(legacy_id: self.metadata['PopProductId'].to_i).or(Product.where(id: Product.decode_id(self.metadata['PopProductId']))).try(:first)
  end


  def lead_date
    po_request = self.purchase_order.po_request
    if po_request.present?
      po_request_rows = po_request.rows
      return false if po_request_rows.blank? || get_product.nil?
      po_request_rows.select {|por_row| por_row.sales_order_row.product == get_product if por_row.sales_order_row}.first.try(:lead_time)
    else
      return false
    end
  end

  def get_pickup_quantity
    self.quantity - self.inward_dispatch_rows.sum(&:reserved_quantity)
  end

  def to_s
    "#{sku ? "#{sku} -" : ''} #{metadata['PopProductName']}"
  end
end
