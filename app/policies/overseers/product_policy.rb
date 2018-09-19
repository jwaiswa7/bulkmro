class Overseers::ProductPolicy < Overseers::ApplicationPolicy
  def pending?
    index?
  end

  def comments?
    record.persisted?
  end

  def approve?
    record.not_approved? && !record.rejected?
  end

  def reject?
    approve?
  end

  def merge?
    approve?
  end

  def customer_bp_catalog?
    index?
  end

  def best_prices_and_supplier_bp_catalog?
    index?
  end
end