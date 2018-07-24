class BrandSupplier < ApplicationRecord
  include Mixins::HasSupplier

  belongs_to :brand

  validates_uniqueness_of :brand, scope: :supplier
end
