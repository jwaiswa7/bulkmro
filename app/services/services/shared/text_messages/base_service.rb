

require "msg91ruby"class Services::Shared::TextMessages::BaseService < Services::Shared::BaseService
  def send_text_message(recipient, to, message, use_alt_provider: false)
    text_message = if recipient.present?
      recipient.text_messages.build
    else
      TextMessage.new
    end

    text_message.assign_attributes(
      to: to,
      message: message,
    )

    if use_alt_provider
      client = Msg91ruby::API.new(Settings.msg91.auth_key, Settings.msg91.sender_id)
      text_message.assign_attributes(
        from: Settings.msg91.sender_id,
        uid: JSON.parse(client.send(
                          text_message.to,
            text_message.message,
            4
        ))["message"]
      )

      text_message.save!
    else
      client = Twilio::REST::Client.new Settings.twilio.account_sid, Settings.twilio.auth_token
      text_message.assign_attributes(
        from: Settings.twilio.phone,
        uid: client.api.account.messages.create(
          messaging_service_sid: Settings.twilio.messaging_service_sid,
          to: text_message.to,
          body: text_message.message
        ).sid
      )

      text_message.save!
    end
  end

  def send_text_messages(recipients, template, substitutions, use_alt_provider: false)
    recipients.each do |recipient|
      send_text_message(recipient, recipient.phone.phone, template % substitutions.merge(name: recipient.to_s), use_alt_provider: use_alt_provider)
    end
  end
end
