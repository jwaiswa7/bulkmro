class SalesReceipt < ApplicationRecord
  include Mixins::CanBeSynced

  belongs_to :sales_invoice
  belongs_to :company
end
