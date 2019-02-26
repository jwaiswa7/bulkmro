# frozen_string_literal: true

module Mixins::IsAPerson
  extend ActiveSupport::Concern

  included do
    has_many :email_messages
    has_many :text_messages

    def full_name
      [first_name, last_name].compact.join(' ').titleize if first_name.present?
    end

    def name
      full_name || ['Contact', id].compact.join(' #')
    end
  end
end
