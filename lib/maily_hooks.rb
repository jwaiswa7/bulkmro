Maily.hooks_for('ApplicationMailer') do |mailer|
end

Maily.hooks_for('InquiryMailer') do |mailer|
  mailer.register_hook(:rfq_generated, RandomRecord.for(Rfq))
end
