class Services::Shared::Notifications::BaseService < Services::Shared::BaseService
  def initialize(from, namespace)
    @from = from
    @namespace = namespace
  end

  def send
    Notification.create(recipient: to, sender: from, namespace: namespace, action: action, notifiable: notifiable, action_url: url, message: message)
  end

  attr_accessor :to, :from, :namespace, :action, :notifiable, :url, :message
end
