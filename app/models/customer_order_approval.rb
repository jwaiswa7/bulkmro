# frozen_string_literal: true

class CustomerOrderApproval < ApplicationRecord
  include Mixins::Customers::CanBeStamped

  belongs_to :customer_order
  after_save :update_inquiry_addresses

  def update_inquiry_addresses
    if self.customer_order.po_reference.present?
      inquiry = Inquiry.where(company_id: self.customer_order.company_id , customer_po_number: self.customer_order.po_reference).last
      inquiry.billing_address_id = self.customer_order.billing_address_id
      inquiry.shipping_address_id = self.customer_order.shipping_address_id
      inquiry.save!
    end
  end
end
