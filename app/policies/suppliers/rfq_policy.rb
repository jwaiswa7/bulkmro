# frozen_string_literal: true

class Suppliers::RfqPolicy < Suppliers::ApplicationPolicy
  def edit_supplier_rfqs?
    true
  end

  def update_supplier_rfqs?
    true
  end
end
