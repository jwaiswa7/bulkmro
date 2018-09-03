class SalesQuote < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  has_one :company, :through => :inquiry
  has_many :inquiry_products, :through => :inquiry
  has_many :sales_products
  accepts_nested_attributes_for :sales_products, reject_if: lambda { |attributes| attributes['inquiry_supplier_id'].blank? && attributes['id'].blank? }
  has_many :products, :through => :sales_products
  has_many :sales_orders

  validates_length_of :sales_products, minimum: 1

  def calculated_total
    sales_products.map { |sales_product| sales_product.unit_selling_price * sales_product.quantity }.sum
  end
end
