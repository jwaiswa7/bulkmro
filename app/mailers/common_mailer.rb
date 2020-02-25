class CommonMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"
  default from: 'no-reply@bulkmro.com'

  def chewy_notification_mail(is_process_started, chewy_time)
    @process_status = is_process_started
    @chewy_time = chewy_time
    if @process_status == true
      subject = 'Chewy Reset Process Started at Sprint'
    else
      subject = 'Chewy Reset Process Completed at Sprint'
    end

    email = mail(to: 'tech@bulkmro.com', subject: subject)
    email.delivery_method.settings = Settings.gmail_smtp.to_hash
    email.delivery_method.settings.merge!(user_name: Settings.itops_mail.user_mail, password: Settings.itops_mail.smtp_password)
  end
end
