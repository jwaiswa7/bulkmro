# frozen_string_literal: true

class CustomerOrderApproval < ApplicationRecord
  include Mixins::Customers::CanBeStamped

  belongs_to :customer_order
  after_save :update_inquiry_addresses

  def update_inquiry_addresses
    if self.customer_order.po_reference.present?
      Services::Customers::CustomerOrders::CreateQuoteAndOrder.new(self.customer_order).call
    end
  end
end
