class Overseers::DashboardPolicy < Overseers::ApplicationPolicy
  def show?
    all_roles?
  end

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