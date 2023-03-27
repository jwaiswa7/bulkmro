class TaskMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def email_task_creation(email_message , assignee)
    @task = email_message.task
    @assignee = assignee
    standard_email(email_message)
  end

end

