# frozen_string_literal: true

class Overseers::ReportPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales?
  end

  def show?
    admin? || manager_or_sales?
  end
  def export_report?
    show?
  end
end
