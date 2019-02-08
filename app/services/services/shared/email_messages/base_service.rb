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
      recipient.email_messages.create!(:to => recipient.email, body: response.body, from: Settings.email_messages.from, uid: response.headers['x-message-id'][0], metadata: response, subject: subject, contact: recipient) if response.present? && response.headers.present?
    else
      recipient.email_messages.create!(:to => recipient.email, body: response.body, from: Settings.email_messages.from, uid: response.headers['x-message-id'][0], metadata: response, subject: subject, overseer: recipient, contact: contact) if response.present? && response.headers.present?
    end

  end

  def send_email_messages(recipients, template_id, template_data, subject)
    personalizations_array = []

    recipients.each do |recipient|
      personalizations_array.push({
                                      to: [{
                                               email: recipient.email,
                                               name: recipient.to_s
                                           }],
                                      dynamic_template_data: template_data.merge(name: recipient.to_s, root_url: routes.root_url)
                                  })
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

    recipients.each do |recipient|

      if Rails.env.production?
        recipient.email_messages.create!(:to => recipient.email, body: response.body, from: Settings.email_messages.from, uid: response.headers['x-message-id'][0], metadata: response, subject: subject, from: Settings.email_messages.from, contact: recipient) if response.present? && response.headers.present?
      else
        recipient.email_messages.create!(:to => recipient.email, body: response.body, from: Settings.email_messages.from, uid: response.headers['x-message-id'][0], metadata: response, subject: subject, from: Settings.email_messages.from, overseer: recipient) if response.present? && response.headers.present?
      end

    end
  end

  attr_accessor :client
end