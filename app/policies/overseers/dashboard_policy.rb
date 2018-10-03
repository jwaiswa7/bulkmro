class Overseers::DashboardPolicy < Overseers::ApplicationPolicy
  def show?
    true
  end

  def chewy?
    true
  end
end