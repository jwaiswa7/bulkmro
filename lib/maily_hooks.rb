# frozen_string_literal: true

Maily.hooks_for("ApplicationMailer") do |mailer|
end

Maily.hooks_for("InquiryMailer") do |mailer|
  mailer.register_hook(:acknowledgement, EmailMessage.new(overseer: RandomRecord.for(Overseer), contact: RandomRecord.for(Contact), inquiry: RandomRecord.for(Inquiry)))
end
