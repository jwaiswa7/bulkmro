class ActivityMailer < ApplicationMailer
    default template_path: "mailers/#{self.name.underscore}"

    def minutes_of_meeting(email_message)
      @overseer = email_message.overseer
      @activity = email_message.activity
      standard_email(email_message)
    end

    def send_minutes_of_meeting(email_message)
      @overseer = email_message.overseer
      @activity = email_message.activity

      attach_files(email_message.files)
      email = htmlized_email(email_message)
      email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
    end

    def follow_up(email_message)
      @overseer = email_message.overseer
      @activity = email_message.activity
      standard_email(email_message)
    end

    def send_follow_up(email_message)
      @overseer = email_message.overseer
      @activity = email_message.activity

      attach_files(email_message.files)
      email = htmlized_email(email_message)
      email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
    end

    def overdue(email_message)
      @overseer = email_message.overseer
      @activity = email_message.activity
      standard_email(email_message)
    end

    def email_of_overdue_to_managers(email_message)
      @activity = email_message.activity
      standard_email(email_message)
    end

    def email_of_pending_approval_to_managers(email_message)
      @activity = email_message.activity
      standard_email(email_message)
    end

    def email_of_overdue_to_upper_management(email_message)
      @activity = email_message.activity
      standard_email(email_message)
    end

    def email_activity_creation(email_message , assignee)
      @activity = email_message.activity
      @assignee = assignee
      standard_email(email_message)
    end

end
