class InquiryMailer < ApplicationMailer
  def rfq_generated(inquiry, company)
    @inquiry = inquiry
    @company = company

    mail template_path: 'mailers', to: "xyz@#{company.name.paramterize}.com", subject: 'This is a test'
  end
end
