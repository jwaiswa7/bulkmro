class Services::Overseers::Activities::UpdateStatus < Services::Shared::BaseService
  def initialize
    super
  end

  def call
    update_status_to_overdue_from_todo()
    update_status_to_overdue_from_pending()  
    send_email_of_overdue_to_manager()
    send_email_of_pending_approval_to_manager()
    send_email_of_overdue_to_upper_management()
    send_email_of_digest_report_to_managers()
  end

  def update_status_to_overdue_from_todo
    activities = Activity.where(activity_status: 'To-Do')
    activities.each do |activity|
      if activity.approved? && activity.approval.created_at.between?(48.hours.ago,24.hours.ago)
        activity.update(activity_status: 'Overdue', status_updated_at: Time.now )
      end
    end
  end

  def update_status_to_overdue_from_pending
    activities = Activity.where(activity_status: 'Pending')
    activities.each do |activity|
      if activity.approved? && activity.approval.created_at.between?(72.hours.ago,48.hours.ago)
        activity.update(activity_status: 'Overdue' , status_updated_at: Time.now )
      end
    end
  end

  def send_email_of_overdue_to_manager
    activities = Activity.where(activity_status: 'Overdue' , status_updated_at: 72.hours.ago..48.hours.ago)
    activities.each do |activity|
      @email_message = activity.email_messages.build(activity: activity ,overseer: Overseer.system_overseer)

      @email_message.assign_attributes(
      to: @activity&.created_by&.parent&.email,
      subject: "Activity Status Overdue",
      body: ActivityMailer.email_of_overdue_to_managers(@email_message).body.raw_source,
      )
      if @email_message.save
        service = Services::Shared::EmailMessages::BaseService.new()
        service.send_email_message_with_sendgrid(@email_message)
      end
    end
  end

  def send_email_of_pending_approval_to_manager
    activities = Activity.where(created_at: 48.hours.ago..24.hours.ago)
    activities.each do |activity|
      if !activity.approved? && !activity.rejected?
        @email_message = activity.email_messages.build(activity: activity ,overseer: Overseer.system_overseer)

        @email_message.assign_attributes(
        to: @activity&.created_by&.parent&.email,
        subject: "Activity Approval Pending",
        body: ActivityMailer.email_of_pending_approval_to_managers(@email_message).body.raw_source,
        )
        if @email_message.save
          service = Services::Shared::EmailMessages::BaseService.new()
          service.send_email_message_with_sendgrid(@email_message)
        end
      end
    end
  end

  def send_email_of_overdue_to_upper_management
    activities = Activity.where(activity_status: 'Overdue' , status_updated_at: 11.days.ago..1.days.ago)
    activities.each do |activity|
      @email_message = activity.email_messages.build(activity: activity ,overseer: Overseer.system_overseer)

      @email_message.assign_attributes(
      cc: ['devang.shah@bulkmro.com ' , 'nikita.shah@bulkmro.com'],
      to: 'gaurang.shah@bulkmro.com',
      subject: "Activity Status Overdue",
      body: ActivityMailer.email_of_overdue_to_upper_management(@email_message).body.raw_source,
      )
      if @email_message.save
        service = Services::Shared::EmailMessages::BaseService.new()
        service.send_email_message_with_sendgrid(@email_message)
        # ActivityMailer.send_email_of_overdue_to_upper_management(@email_message).deliver_now
      end
    end
  end

  def send_email_of_digest_report_to_managers
    activities_with_managers = Activity.left_outer_joins(:approval).where('activity_approvals.id  IS NULL OR activities.activity_status = 40').group_by { |activity| activity.created_by&.parent_id }
    activities_with_managers.each do | manager_id , activities|
      if manager_id.present?
        manager = Overseer.find(manager_id)
        @email_message = activities.first.email_messages.build(overseer: Overseer.system_overseer)
        @email_message.assign_attributes(
            to: manager.email ,
            subject: "Activity Report",
            body: 'Activity Report',
          )
        @email_message.files.attach(io: File.open(RenderCsvToFile.for(activities)), filename: 'daily_digest_report.csv')
        if @email_message.save
          service = Services::Shared::EmailMessages::BaseService.new()
          service.send_email_message_with_sendgrid(@email_message)
        end
      end
    end

  end

end

# Services::Overseers::Activities::UpdateStatus.new().call