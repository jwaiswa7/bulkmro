class Services::Shared::ChatMessages::BaseService < Services::Shared::BaseService
  def initialize
    @client = Slack::Web::Client.new
  end

  def send_chat_message(to, message, attachments)
    puts "IN BASE"
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


# curl -X POST -H 'Authorization: Bearer xoxb-395906857286-467196181812-vQamBs539SJOj14FCakTtd58' -H 'Content-type: application/json' --data '{"channel":"test-channel","text":"I hope the tour went well, Mr. Wonka.","attachments": [{"text":"Who wins the lifetime supply of chocolate?","fallback":"You could be telling the computer exactly what it can do with a lifetime supply of chocolate.","color":"#3AA3E3","attachment_type":"default","callback_id":"select_simple_1234","actions":[{"name":"winners_list","text":"Who should win?","type":"select","data_source":"users"}]}]}' https://slack.com/api/chat.postMessage