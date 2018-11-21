class Overseers::KitProductRowPolicy < Overseers::ApplicationPolicy
  def destroy?
    admin?
  end
end