class Overseers::ProfilePolicy < Overseers::ApplicationPolicy
  def edit?
    all_roles?
  end

  def update?
    edit?
  end
end