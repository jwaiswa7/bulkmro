# frozen_string_literal: true

class Customers::ContactPolicy < Customers::ApplicationPolicy
  def edit_current_company?
    true
  end

  def update_current_company?
    edit_current_company?
  end

  def reset_current_company?
    edit_current_company? && contact.companies.size > 1
  end
end
