class SupplierRfq < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  belongs_to :inquiry_product
  belongs_to :product
  has_many :inquiry_product_suppliers
  has_many :email_messages, dependent: :destroy

  accepts_nested_attributes_for :inquiry_product_suppliers

  enum status: {
      'Draft RFQ: Not Sent': 1,
      'Email Sent: Response Pending': 2,
      'Supplier Responded': 3
  }
end
