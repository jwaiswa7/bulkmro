class ApplicationMailer < ActionMailer::Base
  add_template_helper(DisplayHelper)
  layout 'mailers/layouts/mailer'

  # default from: 'somebody@bulkmro.com'
  # default reply_to: 'sales@bulkmro.com'
  # default from: "from@example.com"
  #

  def routes
    Rails.application.routes.url_helpers
  end

  def standard_email(email_message)
    mail(
      subject: email_message.subject,
      from: email_message.from,
      to: email_message.to,
      cc: email_message.cc,
      bcc: email_message.bcc,
      body: email_message.body
    )
  end

  def htmlized_email(email_message)
    mail(
      subject: email_message.subject,
      from: email_message.from,
      to: email_message.to,
      cc: email_message.cc,
      bcc: email_message.bcc,
      body: email_message.body,
        ) do |format|
      format.html { render html: email_message.body.html_safe }
    end
  end

  def attach_files(files)
    files.each do |file|
      attachments[file.filename.to_s] = file.download
    end
  end
end
