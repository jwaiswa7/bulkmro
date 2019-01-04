class Overseers::ActivityPolicy < Overseers::ApplicationPolicy
  def pending?
    index?
  end

  def approve?
    admin?
  end
  def reject?
    admin?
  end


  def approve_selected?
    admin?
  end
  def reject_selected?
    admin?
  end
end