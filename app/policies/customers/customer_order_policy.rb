class Customers::CustomerOrderPolicy < Customers::ApplicationPolicy
  def order_confirmed?
    true
  end

  def pending_orders?
    manager?
  end

  def approve_order?
    manager?
  end
end