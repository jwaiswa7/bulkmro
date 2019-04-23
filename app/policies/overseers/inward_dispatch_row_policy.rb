class Overseers::InwardDispatchRowPolicy < Overseers::ApplicationPolicy
  def destroy?
    record.inward_dispatch.present? && record.inward_dispatch.status != 'Material Delivered'
  end
end
