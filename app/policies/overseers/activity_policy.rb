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

  def add_to_inquiry?
    admin?
  end

  def perform_actions?
    admin?
  end

  def approve_selected?
    admin?
  end

  def reject_selected?
    admin?
  end

  def edit?
    admin? || (record.created_by == overseer)
  end

  def export_all?
    allow_activity_export?
  end

end
