class SalesQuote < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasAddresses

  belongs_to :inquiry
  has_one :company, :through => :inquiry
  has_many :inquiry_products, :through => :inquiry
  has_many :sales_products
  has_many :products, :through => :sales_products
  accepts_nested_attributes_for :sales_products, reject_if: lambda { |attributes| attributes['product_id'].blank? && attributes['id'].blank? }
  has_one :sales_approval

  validates_length_of :sales_products, minimum: 1
end
