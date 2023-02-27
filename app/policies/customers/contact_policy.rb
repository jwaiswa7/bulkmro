# frozen_string_literal: true

class Customers::ContactPolicy < Customers::ApplicationPolicy
  def admin_columns?
    customer_admin?
  end

  def edit_current_company?
    manager? || customer? || customer_admin?
  end

  def update_current_company?
    edit_current_company?
  end

  def reset_current_company?
    edit_current_company? && contact.account.companies.size > 1
  end

  def amat_columns?
    current_company.id == 5
  end
end
