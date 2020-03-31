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

    def all_orders
      Razorpay::Order.all(count: 100)
    end

    def get_order(order_id)
      Razorpay::Order.fetch(order_id)
    end

    def order_payments(order_id)
      get_order(order_id).payments
    end
  end
end
