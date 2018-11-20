class PurchaseOrderComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :purchase_order_queue

  validates_presence_of :message
end
