class ExportMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"
  default from: 'no-reply@bulkmro.com'

  def export_filtered_records(record, overseer)
    @overseer = overseer
    @export = record
    subject = "Filtered #{record.export_type.titleize} Records"

    attach_files([record.report])
    mail(to: @overseer.email, subject: subject)

  end
end