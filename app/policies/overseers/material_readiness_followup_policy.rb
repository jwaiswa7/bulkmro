class Overseers::MaterialReadinessFollowupPolicy < Overseers::ApplicationPolicy
  def material_pickup_queue?
    admin? || logistics? || sales?
  end

  def material_delivered_queue?
    admin? || logistics? || sales?
  end

  def confirm_delivery?
    admin? || logistics? || sales?
  end
end