class PaymentRequestComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :payment_request
end
