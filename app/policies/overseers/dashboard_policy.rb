class Overseers::DashboardPolicy < Overseers::ApplicationPolicy
  def show?
    all_roles?
  end

  def chewy?
    admin?
  end

  def reset_index?
    admin?
  end

  def migrations?
    admin?
  end

  def console?
    admin?
  end
end