

class OnlinePayment < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasOnlinePayments

  pg_search_scope :locate, against: [:payment_id], associated_against: { customer_order: [:online_order_number] }, using: { tsearch: { prefix: true } }

  belongs_to :customer_order, required: false
  belongs_to :contact, required: false

  validates_uniqueness_of :payment_id

  enum status: {
      'created': 10,
      'authorized': 20,
      'captured': 30,
      'refunded': 40,
      'failed': 50,
  }

  def capture_amount
    (self.customer_order.grand_total * 100).ceil
  end
end
