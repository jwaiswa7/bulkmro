class Overseers::MrfRowPolicy < Overseers::ApplicationPolicy
  def destroy?
    true
  end
end