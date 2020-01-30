class SupplierRfq < ApplicationRecord
  include Mixins::CanBeStamped

  has_many_attached :attachments
  belongs_to :inquiry
  has_many :inquiry_product_suppliers
  has_many :email_messages, dependent: :destroy

  accepts_nested_attributes_for :inquiry_product_suppliers

  enum status: {
      'Draft RFQ: Not Sent': 1,
      'Email Sent: Response Pending': 2,
      'Supplier Responded': 3
  }
end
