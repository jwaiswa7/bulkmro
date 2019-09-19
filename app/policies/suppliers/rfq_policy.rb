# frozen_string_literal: true

class Suppliers::RfqPolicy < Suppliers::ApplicationPolicy
  def edit_supplier_rfq?
    true
  end
end
