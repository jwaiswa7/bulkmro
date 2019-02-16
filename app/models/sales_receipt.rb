class SalesReceipt < ApplicationRecord
  include Mixins::CanBeSynced
  has_many :rows, class_name: 'SalesReceiptRow', dependent: :destroy

  belongs_to :sales_invoice, required: false
  belongs_to :company, required: false
  belongs_to :account, required: false
  belongs_to :sales_order, required: false
  belongs_to :currency, required: false
  scope :with_includes, -> { includes(:company, :sales_order, :sales_invoice, :currency) }
  scope :with_amount_by_invoice, -> { where(payment_type: 'Against Invoice') }
  scope :with_amount_on_account, -> { where(payment_type: 'On Account') }
  scope :total_received_amount, -> { where(payment_type: 'On Account').or(SalesReceipt.where(payment_type: 'against invoice')) }
  has_many :sales_receipt_row
  enum payment_method: {
      'banktransfer': 10,
      'Cheque': 20,
      'checkmo': 30,
      'razorpay': 40,
      'free': 50,
      'roundoff': 60,
      'bankcharges': 70,
      'cash': 80,
      'creditnote': 85,
      'writeoff': 90,
      'Transfer Acct': 95
  }

  enum payment_type: {
      'On Account': 10,
      'Against Invoice': 20,
      'Down Payment': 30,
  }
end
