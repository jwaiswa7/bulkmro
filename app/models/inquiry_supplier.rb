class InquirySupplier < ApplicationRecord
  belongs_to :inquiry_product
  has_one :product, :through => :inquiry_product
  has_one :inquiry, :through => :inquiry_product
  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id

  validates_uniqueness_of :supplier, scope: :inquiry_product
end
