class DcRow < ApplicationRecord
  belongs_to :delivery_challan, class_name: 'DeliveryChallan'
  belongs_to :inquiry_product
  belongs_to :product

  validates_numericality_of :quantity, greater_than: 0, allow_nil: true
end