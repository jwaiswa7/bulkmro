class Services::Overseers::Tasks::UpdateStatus < Services::Shared::BaseService
  def initialize
    super
  end

  def call
    update_status_to_overdue()
    send_email_when_task_due_date_soon()
    send_email_user_manager_after_one_day()
    send_email_user_manager_after_14_days()
    send_mail_when_overdue()
  end

  def update_status_to_overdue
    tasks = Task.where(due_date: Date.today).where.not(status: "Overdue")
    tasks.each do |task|
      task.update(status: 'Overdue')
    end
  end

  def send_email_when_task_due_date_soon
    tasks = Task.where(due_date: 1.days.before..2.days.before)
    tasks.each do |task|
      @email_message = task.email_messages.build(task: task ,overseer: Overseer.system_overseer)
      task.overseers.each do |assignee|
        @email_message.assign_attributes(
        to: assignee.email,
        subject: "Due date is soon",
        body: TaskMailer.email_task_creation(@email_message , assignee).body.raw_source,
        )
        if @email_message.save
          service = Services::Shared::EmailMessages::BaseService.new()
          service.send_email_message_with_sendgrid(@email_message)
        end
      end
    end
  end

  def send_email_user_manager_after_one_day
    tasks = Task.where(due_date: Date.today + 1.day)
    tasks.each do |task|
      @email_message = task.email_messages.build(task: task ,overseer: Overseer.system_overseer)
      task.overseers.each do |assignee|
        @email_message.assign_attributes(
        to: assignee.parent.present? ? assignee.parent.email : task.created_by.email ,
        subject: "Due date is soon",
        body: TaskMailer.email_task_creation(@email_message , assignee).body.raw_source,
        )
        if @email_message.save
          service = Services::Shared::EmailMessages::BaseService.new()
          service.send_email_message_with_sendgrid(@email_message)
        end
      end
    end
  end

  def send_email_user_manager_after_14_days
    tasks = Task.where(due_date: Date.today + 14.days)
    tasks.each do |task|
      @email_message = task.email_messages.build(task: task ,overseer: Overseer.system_overseer)
      task.overseers.each do |assignee|
        @email_message.assign_attributes(
        to: assignee.parent.present? ? assignee.parent.email : "nikita.shah@bulkmro.com" ,
        subject: "Due date is soon",
        body: TaskMailer.email_task_creation(@email_message , assignee).body.raw_source,
        )
        if @email_message.save
          service = Services::Shared::EmailMessages::BaseService.new()
          service.send_email_message_with_sendgrid(@email_message)
        end
      end
    end
  end

  def send_mail_when_overdue
    tasks = Task.where(due_date: Date.today + 30.days)
    mails = ["nikita.shah@bulkmro.com", "nishka.grover@bulkmro.com"]
    tasks.each do |task|
      task.overseers.each do |assignee|
         mails << assignee.email
         mails << assignee.parent&.email
      end
      mails.compact.each do |to|
        @email_message = task.email_messages.build(task: task ,overseer: Overseer.system_overseer)
        @email_message.assign_attributes(
        to: to,
        subject: "Due date is Breached",
        body: TaskMailer.email_task_creation(@email_message , Overseer.find_by_email(to)).body.raw_source,
        )
        if @email_message.save
          service = Services::Shared::EmailMessages::BaseService.new()
          service.send_email_message_with_sendgrid(email_message)
        end
      end
    end
  end

end

# Services::Overseers::Activities::UpdateStatus.new().call

