class Customers::CustomerOrderPolicy < Customers::ApplicationPolicy
  def order_confirmed?
    true
  end

  def pending?
    manager?
  end

  def approve_order?
    manager?
  end
end