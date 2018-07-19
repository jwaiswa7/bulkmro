class BrandSupplier < ApplicationRecord
  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id
  belongs_to :brand

  validates_uniqueness_of :brand, scope: :supplier
end
