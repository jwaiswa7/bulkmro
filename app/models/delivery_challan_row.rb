class DeliveryChallanRow < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasConvertedCalculations
  belongs_to :delivery_challan
  belongs_to :inquiry_product
  belongs_to :product
  belongs_to :sales_order_row
  delegate :sales_quote_row, to: :sales_order_row

  validates_numericality_of :quantity, greater_than: 0, allow_nil: true
end