class PaymentRequestTransaction < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :payment_request
  enum payment_type: {
      :'Cheque' => 10,
      :'NEFT/RTGS' => 20
  }

  validate :amount_paid_exceed?, on: :create
  validates_presence_of :cheque_date, if: :is_payment_type_cheque?

  def amount_paid_exceed?
    if self.amount_paid.present? && self.amount_paid > self.payment_request.remaining_amount
      errors.add(:amount_paid, " should not exceed remaining amount")
    end
  end

  def is_payment_type_cheque?
    self.payment_type == 'Cheque'
  end
end
