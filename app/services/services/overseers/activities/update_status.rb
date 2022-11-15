class Services::Overseers::Activities::UpdateStatus < Services::Shared::BaseService
  def initialize
    super
  end

  def call
    update_status_to_overdue_from_todo()
    update_status_to_overdue_from_pending()  
  end

  def update_status_to_overdue_from_todo
    activities = Activity.where("activity_status = 50 AND status_updated_at < ? ", 24.hours.ago)
    activities.each do |activity|
      if activity.approval_status == 'Approved'
        activity.update(activity_status: 'Overdue')
      end
    end
  end

  def update_status_to_overdue_from_pending
    activities = Activity.where("activity_status = 30 AND status_updated_at < ? ", 48.hours.ago)
    activities.each do |activity|
      if activity.approval_status == 'Approved'
        activity.update(activity_status: 'Overdue')
      end
    end
  end

end
