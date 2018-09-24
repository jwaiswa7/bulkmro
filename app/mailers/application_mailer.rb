class ApplicationMailer < ActionMailer::Base
  add_template_helper(DisplayHelper)
  # default from: 'somebody@bulkmro.com'
  # default reply_to: 'sales@bulkmro.com'
  # default from: "from@example.com"
    layout 'mailer'
end