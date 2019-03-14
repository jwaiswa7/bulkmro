class SalesReceiptRow < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_receipt
  belongs_to :sales_invoice
end
