class CustomerMailer < Devise::Mailer
	include Devise::Mailers::Helpers
	default template_path: 'customers/mailer'
	default from: 'itops@bulkmro.com'

	def reset_password_instructions(record, token, opts = {})
		@user = record
		@token = token
		email = mail(to: @user.email, subject: "Reset password instructions")
		email.delivery_method.settings = Settings.sendgrid_smtp.to_hash
    end
end
