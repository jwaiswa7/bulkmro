class Tag < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :company
  has_many :customer_product_tags
  has_many :customer_products, through: :customer_product_tags

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :company
end
