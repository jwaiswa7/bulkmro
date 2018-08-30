class Overseers::ProductPolicy < Overseers::ApplicationPolicy
  def pending?
    index?
  end

  def new_approval?
    record.not_approved?
  end
end