class MrfRow < ApplicationRecord
  belongs_to :material_readiness_followup
  belongs_to :purchase_order_row

  def reserved_quantity
    self.delivered_quantity.present? ? self.delivered_quantity : self.pickup_quantity
  end

end
