class Tag < ApplicationRecord
  has_many :customer_product_tags
  has_many :customer_products, :through => :customer_product_tags
end
