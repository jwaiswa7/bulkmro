class Overseers::PoRequestRowPolicy < Overseers::ApplicationPolicy
  def destroy?
    true
  end
end
