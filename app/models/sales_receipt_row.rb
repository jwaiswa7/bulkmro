class SalesReceiptRow < ApplicationRecord
  belongs_to :sales_receipt
  belongs_to :sales_invoice
end
