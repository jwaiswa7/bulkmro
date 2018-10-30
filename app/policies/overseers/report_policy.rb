class Overseers::ReportPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales?
  end
end