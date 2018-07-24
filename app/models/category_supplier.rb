class CategorySupplier < ApplicationRecord
  include Mixins::HasSupplier

  belongs_to :category

  validates_uniqueness_of :category, scope: :supplier
end