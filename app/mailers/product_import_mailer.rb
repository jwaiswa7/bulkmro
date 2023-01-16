class ProductImportMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def import_notification(email_message, overseer)
    @overseer = overseer
    standard_email(email_message)
  end

  def send_import_notification(email_message)
    attach_files(email_message.files)
    email = htmlized_email(email_message)
    email.delivery_method.settings = Settings.sendgrid_smtp.to_hash
  end
end
