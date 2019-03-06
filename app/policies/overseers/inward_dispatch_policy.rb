class Overseers::InwardDispatchPolicy < Overseers::ApplicationPolicy
  def inward_dispatch_pickup_queue?
    admin? || logistics? || sales?
  end

  def inward_dispatch_delivered_queue?
    admin? || logistics? || sales?
  end

  def delivered_material?
    true
  end

  def edit?
    admin? || logistics? || sales? && record.status != 'Material Delivered'
  end

  def can_request_invoice?
    !record.invoice_request.present?
  end

  def confirm_delivery?
    record.status == 'Material Pickup'
  end

  def add_products?
    record.status == 'Material Pickup' && !(record.purchase_order.rows.count == 1)
  end

  def remove_products?
    add_products?
  end

  def delivered?
    record.status == 'Material Delivered'
  end

  def update_logistics_owner_for_inward_dispatches?
    admin?
  end
end
