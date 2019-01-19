class Overseers::MprRowPolicy < Overseers::ApplicationPolicy
  def destroy?
    record.material_pickup_request.present? && record.material_pickup_request.status != 'Material Delivered'
  end
end