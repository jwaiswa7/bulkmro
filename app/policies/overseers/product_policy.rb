class Overseers::ProductPolicy < Overseers::ApplicationPolicy
  def pending?
    index?
  end

  def comments?
    record.persisted?
  end

  def approve?
    record.not_approved? && !record.trashed? && !record.disapproved?
  end

  def disapprove?
    approve?
  end

  def reject?
    approve?
  end
end