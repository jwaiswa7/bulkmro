class Overseers::ReportPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales?
  end

  def show?
    admin?
  end

  def bi_report?
    true
  end
end
