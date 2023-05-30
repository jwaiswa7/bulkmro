class CustomerFeedbackMailer < Devise::Mailer
	
    default template_path: "mailers/#{self.name.underscore}"

    def feedback_requested(contact)
       @name = email_message.contact.first_name
       @email = email_message.contact.email
       standard_email(email_message)
    end

	def request_feedback(email_message) 
	   @name = email_message.contact.first_name
	   email = htmlized_email(email_message)
       email.delivery_method.settings = Settings.sendgrid_smtp.to_hash
	end
end
