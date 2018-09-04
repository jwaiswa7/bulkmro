class SalesQuote < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeSent

  has_closure_tree({ name_column: :to_s })

  belongs_to :inquiry
  has_one :company, :through => :inquiry
  has_many :inquiry_products, :through => :inquiry
  has_many :sales_products
  accepts_nested_attributes_for :sales_products, reject_if: lambda { |attributes| attributes['inquiry_supplier_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  has_many :products, :through => :sales_products
  has_many :sales_orders

  validates_length_of :sales_products, minimum: 1
  validates_presence_of :parent_id, :if => :inquiry_has_many_sales_quotes?

  def calculated_total
    sales_products.map { |sales_product| sales_product.unit_selling_price * sales_product.quantity }.sum
  end

  def inquiry_has_many_sales_quotes?
    self.inquiry.sales_quotes.except_object(self).count >= 1
  end
end