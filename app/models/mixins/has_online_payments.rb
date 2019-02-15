module Mixins::HasOnlinePayments
  extend ActiveSupport::Concern

  included do
    def fetch_payment
      razorpay_obj = Razorpay::Payment.fetch(self.payment_id)
      self.update_attributes(metadata: razorpay_obj.to_json, status: razorpay_obj.status, amount: razorpay_obj.amount) if razorpay_obj.present?
      razorpay_obj
    end

    def capture
      if self.fetch_payment.status != 'captured'
        razorpay_obj = Razorpay::Payment.capture(self.payment_id, amount: self.capture_amount)
        self.update_attributes(metadata: razorpay_obj.to_json, status: razorpay_obj.status) if razorpay_obj.present?
      end
    end
  end
end
