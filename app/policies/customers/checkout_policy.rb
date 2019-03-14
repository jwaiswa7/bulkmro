# frozen_string_literal: true

class Customers::CheckoutPolicy < Customers::ApplicationPolicy
  def final_checkout?
    true
  end
end
