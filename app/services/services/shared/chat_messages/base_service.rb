class Services::Shared::ChatMessages::BaseService < Services::Shared::BaseService
  def initialize
    @client = Slack::Web::Client.new
  end

  def send_chat_message(to, message, attachments)
    client.chat_postMessage(
        channel: to,
        text: message,
        icon_emoji: Settings.slack.icon_emoji,
        username: Settings.slack.username,
        attachments: attachments,
        as_user: false
    )

    ChatMessage.create!(to: to, from: Settings.slack.username, message: message, metadata: attachments)
  end

  attr_accessor :client
end