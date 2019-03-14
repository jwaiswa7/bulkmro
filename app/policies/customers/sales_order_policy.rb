# frozen_string_literal: true

class Customers::SalesOrderPolicy < Customers::ApplicationPolicy
  def export_all?
    true
  end
end
