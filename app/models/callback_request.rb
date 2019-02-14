# frozen_string_literal: true

class CallbackRequest < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::IsARequest

  update_index('callback_requests#callback_request') { self }
  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.hits = 0
  end

  scope :sales_order_callbacks, -> (sales_order_id) { where("resource = 'SalesOrder' AND request ->> 'U_MgntDocID' = '#{sales_order_id}'") }
  scope :with_includes, -> { }
  enum resources: {
      'SalesOrder': 10,
      'SalesShipment': 20,
      'SalesReceipt': 30,
      'SalesInvoice': 40,
      'PurchaseOrder': 50,
      'Session': 60
  }
end
