class Services::Overseers::Notifications::Notify < Services::Shared::Notifications::BaseService

  def initialize
    super
  end

  def send(to, from, namespace, action, notifiable, url, message)
    super(to, from, namespace, action, notifiable, url, message)
  end

end