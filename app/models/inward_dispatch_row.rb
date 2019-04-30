class InwardDispatchRow < ApplicationRecord
  belongs_to :inward_dispatch
  belongs_to :purchase_order_row
  has_one :ar_invoice_row

  validates_uniqueness_of :purchase_order_row_id, scope: :inward_dispatch
  validates_numericality_of :pickup_quantity, greater_than: 0
  validates_numericality_of :delivered_quantity, greater_than: 0, allow_nil: true


  def reserved_quantity
    self.delivered_quantity.present? ? self.delivered_quantity : self.pickup_quantity
  end

  after_initialize :set_defaults

  validate :check_pickup_quantity?


  def set_defaults
    self.pickup_quantity ||= purchase_order_row.get_pickup_quantity if purchase_order_row.present?
  end

  def row_product_id
    self.purchase_order_row.get_product.id
  end

  def row_lead_date
    self.purchase_order_row.lead_date if self.purchase_order_row.present?
  end

  def pending_delivery
    self.purchase_order_row.quantity - self.delivered_quantity.to_i
  end

  def check_pickup_quantity?
    previous_pickup_quantity = pickup_quantity_was || 0
    max_quantity = purchase_order_row.get_pickup_quantity + previous_pickup_quantity

    errors.add(:pickup_quantity, " need to be less than or equal to #{max_quantity}") if pickup_quantity > max_quantity
  end

  def to_s
    self.purchase_order_row.to_s
  end

  attr_accessor :quantity
end
