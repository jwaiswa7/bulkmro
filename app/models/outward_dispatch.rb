class OutwardDispatch < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :ar_invoice_request, default: false
  belongs_to :sales_order, default: false
  has_many :packing_slips
end
