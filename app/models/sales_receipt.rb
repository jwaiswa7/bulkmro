class SalesReceipt < ApplicationRecord
  include Mixins::CanBeSynced

  belongs_to :sales_invoice, required: false
  belongs_to :company, required: false
  belongs_to :sales_order, required: false

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
