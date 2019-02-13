class Customers::ReportPolicy < Customers::ApplicationPolicy
  def show?
    true
  end

  def show_aggregate_reports?
    true
  end
end
