module Mixins::IsAPerson
  extend ActiveSupport::Concern

  included do
    has_many :email_messages
    has_many :text_messages

    validates_presence_of :first_name # :last_name

    def full_name
      [first_name, last_name].compact.join(' ')
    end
  end
end