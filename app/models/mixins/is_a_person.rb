module Mixins::IsAPerson
  extend ActiveSupport::Concern

  included do
    has_many :email_messages
    has_many :text_messages

    def full_name
      if first_name.present?
        [first_name, last_name].compact.join(' ')
      else
        ["Contact", id].compact.join(' #')
      end
    end
  end
end