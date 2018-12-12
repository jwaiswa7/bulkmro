class Cart < ApplicationRecord
  belongs_to :contact
  has_many :items, class_name: 'CartItem', dependent: :destroy
  accepts_nested_attributes_for :items
  belongs_to :billing_address, foreign_key: :billing_address_id, :class_name => 'Address', required: false
  belongs_to :shipping_address, foreign_key: :shipping_address_id, :class_name => 'Address', required: false

  after_initialize :set_global_defaults

  def set_global_defaults
    self.billing_address ||= Address.joins(:company).where('companies.id in (?)', contact.companies.map(&:id)).first
    self.shipping_address ||= Address.joins(:company).where('companies.id in (?)', contact.companies.map(&:id)).first
  end

  def calculated_total
    items.inject(0) {|sum, cart_item| sum + cart_item.customer_product.customer_price.to_f * cart_item.quantity}
  end

  def tax_line_items
    grouped_items = items.joins(:customer_product).group_by(&:best_tax_rate)
    tax_items = {}

    grouped_items.each do |tax_rate, items|
      tax_items[tax_rate.tax_percentage.to_f] ||= 0

      tax_items[tax_rate.tax_percentage.to_f] += items.map do |item|
        item.quantity * item.customer_product.customer_price * tax_rate.tax_percentage.to_f / 100
      end.sum
    end

    tax_items
  end

  def calculated_total_tax
    items.map do |cart_item|
      cart_item.customer_product.customer_price * cart_item.quantity * cart_item.customer_product.best_tax_rate.tax_percentage / 100
    end.sum
  end

  def grand_total
    calculated_total + calculated_total_tax
  end

  def default_warehouse_address
    Warehouse.default.address
  end
end
