class Services::Overseers::FailedRemoteRequests::Resync < Services::Shared::BaseService
  def initialize
    @client = Slack::Web::Client.new
  end

  def call
    @service = Services::Shared::Snippets.new
    request = @service.resend_failed_remote_requests
    message = [{"title": "Total requests initiated", "text": +request[1].to_s, "color": "#439FE0"}]
    title = "*Resync requests initiated at* "+ Time.now.to_s
    self.send_chat_message(title, message)
  end

  def send_chat_message(title, message)
    client.chat_postMessage(
        channel: "GDRG23Z7F",
        icon_emoji: Settings.slack.icon_emoji,
        username: Settings.slack.username,
        text: title,
        attachments: message,
        as_user: true
    )
  end

  def verify
    title = "*Resync requests status at* "+ Time.now.to_s
    resync_request = ResyncRequest.initiated_today.last
    if resync_request.present?
      requests = resync_request.request
      total = requests.count
      success = 0
      failed = 0
      pending = 0
      requests.each do |request|
        parsed_request = request.split('~')
        status =  RemoteRequest.find_by_subject_type_and_subject_id(parsed_request[0],parsed_request[1]).latest_status
        case status
        when 'pending'
          pending += 1
        when 'success'
          success += 1
        else
          failed += 1
        end
      end
      message = [
              {
                  "title": "Total requests",
                  "text": total.to_s,
                  "color": "#439FE0"
              },
              {
                  "title": "Success",
                  "text": success.to_s,
                  "color": "good"
              },
              {
                  "title": "Pending",
                  "text": pending.to_s,
                  "color": "warning"
              },
              {
                  "title": "Failed",
                  "text": failed.to_s,
                  "color": "danger"
              }
          ]
      resync_request.update_attribute(:status, "addressed")
    else
      message = [
          {
              "title": "Requests not found",
              "color": "#439FE0"
          }
      ]
    end
    self.send_chat_message(title,message)
  end


  attr_accessor :client
end