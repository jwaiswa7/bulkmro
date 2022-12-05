class CompanyCreationRequestMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def approved(email_message)
    @company_name = email_message.activity.company_creation_request.company&.name
    standard_email(email_message)
  end


  def rejected(email_message)
    @company_name = email_message.activity.company_creation_request.company&.name
    standard_email(email_message)
  end
end
