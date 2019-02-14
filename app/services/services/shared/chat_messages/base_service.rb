

class Services::Shared::ChatMessages::BaseService < Services::Shared::BaseService
  def initialize
    @client = Slack::Web::Client.new
  end

  def send_chat_message(to, message)
    client.chat_postMessage(
      channel: to,
      icon_emoji: Settings.slack.icon_emoji,
      username: Settings.slack.username,
      attachments: message,
      as_user: true
    )

    ChatMessage.create!(to: to, from: Settings.slack.username, message: message)
  end

  def message_body(fallback: nil, pretext: nil, author_name: nil, inquiry_number: nil, order_no: nil)
    [
        {
           "fallback": fallback,
           "color": 'warning',
           "pretext": pretext,
           "author_name": author_name,
           "title": 'Order Details',
           "fields": [
               {
                   "title": 'Inquiry',
                   "value": inquiry_number,
                   "short": true
               },
               {
                   "title": 'Order Number',
                   "value": order_no,
                   "short": true
               }
           ],
           # "image_url": "http://my-website.com/path/to/image.jpg",
           # "thumb_url": "http://example.com/path/to/thumb.png",
           "footer": 'For issues, usersnap us'
           # "footer_icon": "",
           # "ts": Time.now()
        }
    ]
  end

  attr_accessor :client
end
