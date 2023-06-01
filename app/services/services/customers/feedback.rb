class Services::Customers::Feedback
  def initialize(company_id)
    @company_id = company_id
  end

  def call
    company = Company.find(@company_id)

    company.contacts.each do |contact|
        send_email(contact)

    end
    {success: true, message: 'Feedback request sent successfully'}
  end

  private 

  def send_email(contact)
    email_message = EmailMessage.new(contact: contact)
    email_message.assign_attributes(
      subject: 'Your feedback is important to us',
      body: CustomerFeedbackMailer.feedback_requested(email_message).body.raw_source,
      from: 'itops@bulkmro.com',
      to: contact.email
    )

    if email_message.save
      CustomerFeedbackMailer.request_feedback(email_message).deliver_now
    end
    
  end

  attr_accessor :company
end
