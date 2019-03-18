class ExportMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"
  default from: 'no-reply@bulkmro.com'

  def export_filtered_records(record, overseer)
    @overseer = overseer
    @export = record
    subject = "Filtered #{record.export_type.titleize} Records"

    attach_files([record.report])
    email = mail(to: @overseer.email, subject: subject)
    email.delivery_method.settings = Settings.gmail_smtp.to_hash
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
  end
end
