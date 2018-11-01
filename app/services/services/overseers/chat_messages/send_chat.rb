class Services::Overseers::ChatMessages::SendChat < Services::Shared::ChatMessages::BaseService

  def initialize
    super
  end

  def send_chat_message(to,message,attachments)
    super(to,message,attachments)
    puts "In send chat"
  end

end