class Customers::ProfilePolicy < Customers::ApplicationPolicy
  def edit?
    true
  end

  def update?
    edit?
  end
end