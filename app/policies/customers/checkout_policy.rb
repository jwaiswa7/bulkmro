# frozen_string_literal: true

class Customers::CheckoutPolicy < Customers::ApplicationPolicy
  def final_checkout?
    true
  end

  def customer_po_autocomplete?
    true
  end
end
