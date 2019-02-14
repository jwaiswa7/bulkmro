class CategorySupplier < ApplicationRecord
  belongs_to :category

  validates_uniqueness_of :category, scope: :supplier
end
