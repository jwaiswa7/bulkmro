class SalesQuote < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeSent

  has_closure_tree({ name_column: :to_s })

  belongs_to :inquiry
  has_one :company, :through => :inquiry
  has_many :inquiry_products, :through => :inquiry
  has_many :rows, class_name: 'SalesQuoteRow', inverse_of: :sales_quote
  accepts_nested_attributes_for :rows, reject_if: lambda { |attributes| attributes['inquiry_product_supplier_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  has_many :products, :through => :rows
  has_many :sales_orders

  validates_length_of :rows, minimum: 1
  validates_presence_of :parent_id, :if => :inquiry_has_many_sales_quotes?

  def calculated_total
    rows.map { |row| row.unit_selling_price * row.quantity }.sum
  end

  def inquiry_has_many_sales_quotes?
    self.inquiry.sales_quotes.except_object(self).count >= 1
  end
end