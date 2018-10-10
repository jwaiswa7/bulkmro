class PurchaseOrder < ApplicationRecord
  belongs_to :inquiry
  has_many :rows, class_name: 'PurchaseOrderRow', inverse_of: :purchase_order
end
