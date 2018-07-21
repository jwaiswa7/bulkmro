class InquiryMailer < ApplicationMailer
  def rfq_generated(rfq)
    @rfq = rfq

    mail template_path: 'mailers/inquiry_mailer', to: "xyz@#{@rfq.supplier.name.parameterize}.com", subject: 'This is a test'
  end
end