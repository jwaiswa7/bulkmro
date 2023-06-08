class CustomerFeedbackMailer < ApplicationMailer
	
    default template_path: "mailers/#{self.name.underscore}"

    def feedback_requested(email_message)
       @email = email_message.to
       standard_email(email_message)
    end

	def request_feedback(email_message) 
      @overseer = email_message.overseer
	   email = htmlized_email(email_message)
      email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
	end
end
