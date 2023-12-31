require 'sendgrid-ruby'
include SendGrid

class Services::Shared::EmailMessages::BaseService < Services::Shared::BaseService
  def initialize
    @client = SendGrid::API.new(api_key: Settings.sendgrid.api_key)
  end

  def send_email_message(recipient, template_id, template_data, subject, contact= nil)
    response = client.client.mail._('send').post(request_body: {
        from: {
            email: Settings.email_messages.from,
            name: Settings.email_messages.from_name
        },
        reply_to: {
            email: Settings.email_messages.reply_to,
            name: Settings.email_messages.reply_to_name
        },
        personalizations: [
            to: [{
                     email: recipient.email,
                     name: recipient.to_s
                 }],
            dynamic_template_data: template_data.merge(root_url: routes.root_url)
        ],
        template_id: template_id
    }.as_json)

    if Rails.env.production?
      recipient.email_messages.create!(to: recipient.email, body: response.body, from: Settings.email_messages.from, uid: response.headers['x-message-id'][0], metadata: response, subject: subject, contact: recipient, template_data: template_data) if response.present? && response.headers.present?
    else
      recipient.email_messages.create!(to: recipient.email, body: response.body, from: Settings.email_messages.from, uid: response.headers['x-message-id'][0], metadata: response, subject: subject, overseer: recipient, contact: contact, template_data: template_data) if response.present? && response.headers.present?
    end
  end

  def send_email_messages(recipients, template_id, template_data, subject, contact = nil)
    personalizations_array = []

    recipients.each do |recipient|
      personalizations_array.push(
        to: [{
                 email: recipient.email,
                 name: recipient.to_s
             }],
        dynamic_template_data: template_data.merge(name: recipient.to_s, root_url: routes.root_url)
                                  )
    end

    response = client.client.mail._('send').post(request_body: {
        from: {
            email: Settings.email_messages.from,
            name: Settings.email_messages.from_name
        },
        reply_to: {
            email: Settings.email_messages.reply_to,
            name: Settings.email_messages.reply_to_name
        },
        personalizations: personalizations_array.as_json,
        template_id: template_id
    }.as_json)

    recipients.each_with_index do |recipient, index|
      contact_or_recipient = recipient.class.name == "Overseer" ? nil : recipient
      if Rails.env.production?
        recipient.email_messages.create!(to: recipient.email, body: response.body, from: Settings.email_messages.from, uid: response.headers['x-message-id'][0], metadata: response, subject: subject, from: Settings.email_messages.from, contact: contact_or_recipient, template_data: template_data) if response.present? && response.headers.present?
      else
        recipient.email_messages.create!(to: recipient.email, body: response.body, from: Settings.email_messages.from, uid: response.headers['x-message-id'][0], metadata: response, subject: subject, from: Settings.email_messages.from, contact: contact_or_recipient, template_data: template_data) if response.present? && response.headers.present?
      end
    end
  end

  def send_email_message_with_sendgrid(email_message)
    mail = SendGrid::Mail.new
    mail.from = Email.new(email: 'itops@bulkmro.com')
    mail.subject = email_message.subject
    personalization = Personalization.new
    personalization.add_to(Email.new(email: email_message.to)) 
    email_message.cc.each do |cc|
      personalization.add_cc(Email.new(email: cc))  
    end if email_message.cc.present?
    
    mail.add_personalization(personalization)
    mail.add_content(Content.new(type: 'text/html', value: email_message.body))
    email_message.files.each do |file|
      attachment = Attachment.new
      attachment.content = Base64.strict_encode64(file.download.to_s)
      attachment.type = file.content_type
      attachment.filename = file.filename.to_s
      mail.add_attachment(attachment)
    end if email_message.files.present?

    client.client.mail._('send').post(request_body: mail.to_json)
  end

  attr_accessor :client
end
