class Overseers::DashboardPolicy < Overseers::ApplicationPolicy
  def show?
    true
  end

  def chewy?
    admin?
  end

  def migrations?
    admin?
  end
end