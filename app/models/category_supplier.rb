class CategorySupplier < ApplicationRecord
  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id
  belongs_to :category

  validates_uniqueness_of :category, scope: :supplier
end