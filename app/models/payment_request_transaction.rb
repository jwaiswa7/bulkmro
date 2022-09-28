class PaymentRequestTransaction < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :payment_request
  enum payment_type: {
      'Cheque': 10,
      'NEFT/RTGS': 20
  }

  enum status: {
      'Pending': 10,
      'Rejected': 20,
      'On Hold': 30,
      'Completed': 40,
      'Refund': 50,
      'Cancelled': 60
  }

  validate :amount_paid_exceed?, on: :create
  validates_presence_of :cheque_date, :issue_date, if: :is_payment_type_cheque?

  def amount_paid_exceed?
    if self.amount_paid.present? && self.amount_paid > self.payment_request.remaining_amount
      errors.add(:amount_paid, ' should not exceed remaining amount')
    end
  end

  def is_payment_type_cheque?
    self.payment_type == 'Cheque'
  end
end
