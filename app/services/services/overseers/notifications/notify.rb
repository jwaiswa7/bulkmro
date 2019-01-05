class Services::Overseers::Notifications::Notify < Services::Shared::Notifications::BaseService

  def initialize(from, namespace)
    super(from, namespace)
  end

  def send_product_import_confirmation(tos, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = "#{msg[0]} uploaded for approval in Inquiry ##{msg[1]}"
    tos.each do | to |
      @to = to
      send
    end
  end
  def send_product_comment(to, action, notifiable, url, *msg)
    @to = to; @action = action; @notifiable = notifiable; @url = url

    if msg[0].present?
      @message = "Product #{msg[1]} has been #{msg[0]}"
    else
      @message =  "New reply for Product #{msg[1]}"
    end
    @message =  "#{message.to_s}: #{msg[2]}" if msg[2].present?
    send
  end

end