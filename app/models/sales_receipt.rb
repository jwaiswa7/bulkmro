class SalesReceipt < ApplicationRecord
  belongs_to :sales_invoice
  has_many :rows, :class_name => 'SalesReceiptRow', inverse_of: :sales_receipt
end
