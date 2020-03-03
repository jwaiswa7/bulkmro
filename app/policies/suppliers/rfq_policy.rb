# frozen_string_literal: true

class Suppliers::RfqPolicy < Suppliers::ApplicationPolicy
  def edit_supplier_rfqs?
    true
  end

  def edit_rfq?
    true
  end

  def update_ips?
    true
  end
end
