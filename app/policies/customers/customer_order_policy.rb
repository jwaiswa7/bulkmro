class Customers::CustomerOrderPolicy < Customers::ApplicationPolicy
  def order_confirmed?
    true
  end
end