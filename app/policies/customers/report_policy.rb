# frozen_string_literal: true

class Customers::ReportPolicy < Customers::ApplicationPolicy
  def show?
    true
  end

  def show_aggregate_reports?
    true
  end

  def stock_reports?
    # Show stock report only for Henkel Account
    contact.account_id == 2431
  end
end
