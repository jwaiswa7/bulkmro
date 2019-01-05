class Services::Overseers::Notifications::Notify < Services::Shared::Notifications::BaseService

  def initialize(from, namespace)
    super(from, namespace)
  end

  def send_product_import_confirmation(tos, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message =  "#{msg[0]} uploaded for approval in Inquiry ##{msg[1]}"
    tos.each do | to |
      @to = to
      send
    end
  end

end