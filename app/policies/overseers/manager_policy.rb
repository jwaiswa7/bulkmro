class Overseers::ManagerPolicy < Overseers::ApplicationPolicy
  def new?
    manager?
  end

  def edit?
    new?
  end

  def create?
    new?
  end
end