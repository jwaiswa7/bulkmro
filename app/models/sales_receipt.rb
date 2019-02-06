class SalesReceipt < ApplicationRecord
  include Mixins::CanBeSynced

  belongs_to :sales_invoice, required: false
  belongs_to :company, required: false
  belongs_to :sales_order, required: false
  belongs_to :currency, required: false
  scope :with_includes, -> {includes(:company, :sales_order,:sales_invoice,:currency)}
  enum payment_method: {
      :'banktransfer' => 10,
      :'Cheque' => 20,
      :'checkmo' => 30,
      :'razorpay' => 40,
      :'free' => 50,
      :'roundoff' => 60,
      :'bankcharges' => 70,
      :'cash' => 80,
      :'creditnote' => 85,
      :'writeoff' => 90,
      :'Transfer Acct' => 95
  }

  enum payment_type: {
      :'on account' => 10,
      :'against invoice' => 20,
      :'down payment' => 30,
  }
end
