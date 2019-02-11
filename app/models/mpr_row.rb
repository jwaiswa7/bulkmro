class MprRow < ApplicationRecord
  belongs_to :material_pickup_request
  belongs_to :purchase_order_row

  validates_uniqueness_of :purchase_order_row_id, scope: :material_pickup_request
  validates_numericality_of :pickup_quantity, greater_than: 0
  validates_numericality_of :delivered_quantity, greater_than: 0, :allow_nil => true


  def reserved_quantity
    self.delivered_quantity.present? ? self.delivered_quantity : self.pickup_quantity
  end

  after_initialize :set_defaults

  validate :check_pickup_quantity?


  def set_defaults
    self.pickup_quantity ||= purchase_order_row.get_pickup_quantity if purchase_order_row.present?
  end

  def row_product_id
    purchase_order_row.get_product.id
  end

  def lead_date
    po_request = purchase_order_row.purchase_order.po_request
    if po_request.present?
      po_request_rows = po_request.rows.where.not(product_id: nil)
      return false if po_request_rows.blank? || row_product_id.nil?

      po_request_rows.where(product_id: row_product_id).first.try(:lead_time)
    else
      return false
    end
  end


  def check_pickup_quantity?

    previous_pickup_quantity = pickup_quantity_was || 0
    max_quantity = purchase_order_row.get_pickup_quantity + previous_pickup_quantity

    errors.add(:pickup_quantity, " need to be less than or equal to #{max_quantity}") if pickup_quantity > max_quantity
  end

  attr_accessor :quantity
end
