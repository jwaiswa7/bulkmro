class Customers::ReportPolicy < Customers::ApplicationPolicy
  def show?
    true
  end

  def monthly_purchase_data?
    true
  end
end