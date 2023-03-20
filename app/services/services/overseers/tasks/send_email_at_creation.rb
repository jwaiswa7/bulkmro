class Services::Overseers::Tasks::SendEmailAtCreation < Services::Shared::BaseService
  def initialize(task, current_overseer)
    @task = task
    @current_overseer = current_overseer
  end

  def call
    @task.overseers.each do |assignee|
      @email_message = @task.email_messages.build(task: @task ,overseer: @current_overseer)
      @email_message.assign_attributes(
      to: assignee.email,
      subject: "Task is Created",
      body: TaskMailer.email_task_creation(@email_message , assignee).body.raw_source,
      )
      if @email_message.save
        service = Services::Shared::EmailMessages::BaseService.new()
        service.send_email_message_with_sendgrid(@email_message)

      end
    end
  end
  attr_accessor :task, :current_overseer

end



