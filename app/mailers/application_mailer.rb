class ApplicationMailer < ActionMailer::Base
  add_template_helper(DisplayHelper)
  default from: 'somebody@bulkmro.com'
  default reply_to: 'sales@bulkmro.com'
  layout 'mailers/layouts/mailer'
end