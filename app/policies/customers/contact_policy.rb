class Customers::ContactPolicy < Customers::ApplicationPolicy
  def choose_company?
    true
  end

  def reset_company?
    true
  end
end