class PackingSlipRow < ApplicationRecord
  belongs_to :packing_slip, default: false
  belongs_to :ar_invoice_request_row, default: false
  validates_numericality_of :delivery_quantity, greater_than: 0, allow_nil: true
  validate :check_delivery_quantity?


  def check_delivery_quantity?
    previous_delivery_quantity = delivery_quantity_was || 0
    max_quantity = ar_invoice_request_row.get_remaining_quantity + previous_delivery_quantity

    errors.add(:delivery_quantity, " need to be less than or equal to #{max_quantity}") if delivery_quantity > max_quantity
  end

end
