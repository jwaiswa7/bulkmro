class Services::Shared::ChatMessages::BaseService < Services::Shared::BaseService
  def initialize
    @client = Slack::Web::Client.new
  end

  def send_chat_message(to, message, attachments)
    client.chat_postMessage(
        channel: to,
        text: message,
        icon_emoji: ':moneybag:',
        username: 'Sprint Bot',
        attachments: attachments,
        as_user: false
    )

    ChatMessage.create!(to: to, message: message)
  end

  attr_accessor :client
end