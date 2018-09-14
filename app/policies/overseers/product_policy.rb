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

  def best_prices_and_bp_catalog?
    index?
  end

  def bp_catalog?
    index?
  end
end