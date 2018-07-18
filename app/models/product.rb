class Product < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :brand
  has_many :companies, :through => :brand

  validates_presence_of :name, :sku
end
