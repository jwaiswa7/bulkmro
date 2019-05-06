class PackingSlip < ApplicationRecord
  belongs_to :outward_dispatch, required: false
  has_many :rows, class_name: 'PackingSlipRow', inverse_of: :packing_slip
  include Mixins::CanBeStamped
  accepts_nested_attributes_for :rows, reject_if: lambda { |attributes| attributes['ar_invoice_request_row_id'].blank? && attributes['id'].blank? }, allow_destroy: true

  def dispatched_quntity
    self.rows.sum(:delivery_quantity)
  end
end
