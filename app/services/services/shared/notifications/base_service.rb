class Services::Shared::Notifications::BaseService < Services::Shared::BaseService
  def initialize
    @client = Slack::Web::Client.new
  end

  def send(to, from, namespace, action, notifiable, url, message)
    Notification.create(recipient: to, sender: from, namespace: namespace, action: action, notifiable: notifiable, action_url:url, message: message)
  end

  attr_accessor :client
end