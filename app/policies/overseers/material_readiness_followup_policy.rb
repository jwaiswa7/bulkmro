class Overseers::MaterialReadinessFollowupPolicy < Overseers::ApplicationPolicy
  def material_pickup_queue?
    admin? || logistics? || sales?
  end

  def material_delivered_queue?
    admin? || logistics? || sales?
  end

  def edit?
    admin? || logistics? || sales? &&   record.status != 'Material Delivered'
  end

  def confirm_delivery?
    record.status == 'Material Pickup'
  end
end