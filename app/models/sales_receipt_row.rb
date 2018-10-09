class SalesReceiptRow < ApplicationRecord
  belongs_to :sales_receipt
  belongs_to :sales_invoice

  validates_presence_of :amount

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.amount ||= 0.0
  end
end
