class Services::Overseers::Activities::UpdateStatus < Services::Shared::BaseService
  def initialize
    super
  end

  def call
    update_status_to_overdue_from_todo()
    update_status_to_overdue_from_pending()  
    send_email_of_overdue_to_manger()
    send_email_of_pending_approval_to_manger()
    send_email_of_overdue_to_upper_management()
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

  def send_email_of_overdue_to_manger
    activities = Activity.where(activity_status: 'Overdue' , status_updated_at: 72.hours.ago..48.hours.ago)
    activities.each do |activity|
      @email_message = activity.email_messages.build(activity: activity ,overseer: Overseer.system_overseer)

      @email_message.assign_attributes(
      to: @activity&.created_by&.parent&.email,
      subject: "Activity Status Overdue",
      body: ActivityMailer.email_of_overdue_to_mangers(@email_message).body.raw_source,
      )
      if @email_message.save
        service = Services::Shared::EmailMessages::BaseService.new()
        service.send_email_message_with_sendgrid(@email_message)
      end
    end
  end

  def send_email_of_pending_approval_to_manger
    activities = Activity.where(created_at: 48.hours.ago..24.hours.ago)
    activities.each do |activity|
      if !activity.approved? && !activity.rejected?
        @email_message = activity.email_messages.build(activity: activity ,overseer: Overseer.system_overseer)

        @email_message.assign_attributes(
        to: @activity&.created_by&.parent&.email,
        subject: "Activity Approval Pending",
        body: ActivityMailer.email_of_pending_approval_to_mangers(@email_message).body.raw_source,
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

end

# Services::Overseers::Activities::UpdateStatus.new().call