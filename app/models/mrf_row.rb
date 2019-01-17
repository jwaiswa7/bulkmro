class MrfRow < ApplicationRecord
  belongs_to :material_readiness_followup
  belongs_to :purchase_order_row #, ->(record){where(purchase_order_id: record.material_readiness_followup.purchase_order.id)}

  validates_uniqueness_of :purchase_order_row, scope: :material_readiness_followup

  def reserved_quantity
    self.delivered_quantity.present? ? self.delivered_quantity : self.pickup_quantity
  end

  after_initialize :set_defaults

  validate :check_pickup_quantity?


  def set_defaults
    self.pickup_quantity ||= purchase_order_row.get_pickup_quantity if purchase_order_row.present?
  end

  def check_pickup_quantity?
    raise
    if self.pickup_quantity > self.purchase_order_row.quantity
      errors.add(:pickup_quantity, " need to be less than or equal to #{purchase_order_row.get_pickup_quantity}")
    end
  end

  attr_accessor :quantity
end
