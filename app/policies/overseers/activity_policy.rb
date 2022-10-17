class Overseers::ActivityPolicy < Overseers::ApplicationPolicy
  def pending?
    index?
  end

  def approve?
    admin_or_manager? 
  end
  def reject?
    admin_or_manager? 
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
    (admin? || (record.created_by == overseer)) && record.approval_status == 'Pending Approval' 
  end

  def export_all?
    allow_activity_export?
  end

  def send_email?
    admin_or_manager? 
  end
end
