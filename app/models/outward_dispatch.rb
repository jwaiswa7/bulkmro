class OutwardDispatch < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :ar_invoice_request, default: false
  belongs_to :sales_order, default: false
  has_many :packing_slips
  scope :with_includes, -> { }
  update_index('outward_dispatches#outward_dispatch') {self}

  enum status: {
      'Material Ready for Dispatch': 10,
      'Dispatch Approval Pending': 20,
      'Dispatch Rejected': 30,
      'Material In Trainsit': 40,
      'Material Delivered Pending GRN': 50,
      'Material Delivered': 60
  }

  def quantity_in_payment_slips
    self.packing_slips.sum(&:dispatched_quntity)
  end
end
