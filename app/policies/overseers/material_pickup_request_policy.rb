class Overseers::MaterialPickupRequestPolicy < Overseers::ApplicationPolicy
  def material_pickup_queue?
    admin? || logistics? || sales?
  end


  def material_delivered_queue?
    admin? || logistics? || sales?
  end

  def delivered_material?
    true
  end

  def edit?
    admin? || logistics? || sales? && record.status != 'Material Delivered'
  end

  def confirm_delivery?
    record.status == 'Material Pickup'
  end

  def add_products?
    record.status == 'Material Pickup'
  end

  def delivered?
    record.status == 'Material Delivered'
  end

end