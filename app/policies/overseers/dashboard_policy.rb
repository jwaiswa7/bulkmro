class Overseers::DashboardPolicy < Overseers::ApplicationPolicy
  def show?
    all_roles?
  end

  def chewy?
    developer?
  end

  def reset_index?
    developer?
  end

  def migrations?
    admin?
  end

  def console?
    admin?
  end
end