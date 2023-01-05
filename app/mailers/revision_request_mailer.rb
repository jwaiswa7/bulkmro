class RevisionRequestMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"


  def request_submitted(email_message, revision_request, inquiry)
    @revision_request = revision_request
    @inquiry = inquiry
    standard_email(email_message)
  end

  def send_submited_request(email_message)
    attach_files(email_message.files)
    email = htmlized_email(email_message)
    email.delivery_method.settings = Settings.sendgrid_smtp.to_hash
  end
end
