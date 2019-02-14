

class Overseers::KitProductRowPolicy < Overseers::ApplicationPolicy
  def destroy?
    admin? || cataloging?
  end
end
