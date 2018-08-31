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
end