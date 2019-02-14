module Mixins::HasNotifications
  extend ActiveSupport::Concern

  included do
    after_commit :send_notification, on: :update

    def send_notification
      chat_message = Services::Overseers::ChatMessages::SendChat.new
      chat_message.send_chat_message('user', 'Bot speaking')
    end
  end
end
