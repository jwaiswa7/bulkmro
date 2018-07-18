class InquiryProduct < ApplicationRecord
  belongs_to :inquiry
  belongs_to :product

  validates_presence_of :quantity
  validates_uniqueness_of :product, scope: :inquiry
  validates_numericality_of :quantity, :greater_than => 0
end
