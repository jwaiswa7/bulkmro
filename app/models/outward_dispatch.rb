class OutwardDispatch < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :ar_invoice_request, default: false
  belongs_to :sales_order, default: false
  has_many :packing_slips
  scope :with_includes, -> { }
  update_index('outward_dispatches#outward_dispatch') {self}

end
