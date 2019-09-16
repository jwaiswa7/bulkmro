class SupplierRfq < ApplicationRecord
  belongs_to :inquiry
  belongs_to :inquiry_product
  belongs_to :inquiry_product_supplier
  belongs_to :product

  enum status: {
      'Supplier Response Pending': 1,
      'Supplier Responded': 2
  }
end
