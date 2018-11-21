class Customers::ReportPolicy < Customers::ApplicationPolicy
  def show?
    true
  end
end