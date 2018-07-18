class Brand < ApplicationRecord
  include Mixins::CanBeStamped

  has_many :company_brands
  has_many :companies, :through => :company_brands
  accepts_nested_attributes_for :company_brands
  has_many :products
end
