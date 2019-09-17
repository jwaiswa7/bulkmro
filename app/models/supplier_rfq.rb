class SupplierRfq < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  belongs_to :inquiry_product
  belongs_to :inquiry_product_supplier
  belongs_to :product
  has_many :email_messages, dependent: :destroy

  enum status: {
      'RFQ created: Not Sent': 1,
      'Supplier Response Pending': 2,
      'Supplier Responded': 3
  }
end
