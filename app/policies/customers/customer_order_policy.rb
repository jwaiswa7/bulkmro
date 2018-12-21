class Customers::CustomerOrderPolicy < Customers::ApplicationPolicy
  def order_confirmed?
    true
  end

  def pending?
    manager?
  end

  def approved?
    true
  end

  def approve_order?
    manager?
  end

  def approve?
    record.not_approved? && !record.rejected?
  end

  def reject?
    approve?
  end
end