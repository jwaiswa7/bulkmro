module Mixins::HasPayments
  extend ActiveSupport::Concern

  included do
    def fetch_payment(raz_payment_id)
      Razorpay::Payment.fetch(raz_payment_id)
    end
  end
end