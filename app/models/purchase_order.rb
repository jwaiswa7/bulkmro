class PurchaseOrder < ApplicationRecord
  belongs_to :inquiry
  has_many :rows, class_name: 'PurchaseOrderRow', inverse_of: :purchase_order

  has_one_attached :po_pdf

  validates_with FileValidator, attachment: :po_pdf, file_size_in_megabytes: 2
end
