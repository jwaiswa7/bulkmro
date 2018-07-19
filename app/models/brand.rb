class Brand < ApplicationRecord
  include Mixins::CanBeStamped

  has_many :brand_suppliers
  has_many :suppliers, :through => :brand_suppliers
  has_many :products
end