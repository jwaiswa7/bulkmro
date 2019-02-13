class BrandSupplier < ApplicationRecord
  belongs_to :brand

  validates_uniqueness_of :brand, scope: :supplier
end
