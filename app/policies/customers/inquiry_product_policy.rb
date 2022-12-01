# frozen_string_literal: true

class Customers::InquiryProductPolicy < Customers::ApplicationPolicy
  def destroy?
    true
  end
end
