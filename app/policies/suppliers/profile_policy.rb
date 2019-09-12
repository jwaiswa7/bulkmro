class Suppliers::ProfilePolicy < Suppliers::ApplicationPolicy
  def edit?
    true
  end

  def update?
    edit?
  end
end
