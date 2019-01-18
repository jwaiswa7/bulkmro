class Overseers::MrfRowPolicy < Overseers::ApplicationPolicy
  def destroy?
    record.material_readiness_followup.present? && record.material_readiness_followup.status != 'Material Delivered'
  end
end