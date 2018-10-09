class Overseers::DashboardPolicy < Overseers::ApplicationPolicy
  def chewy?
    admin?
  end

  def migrations?
    admin?
  end

  def console?
    admin?
  end
end