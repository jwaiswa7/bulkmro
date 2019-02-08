# frozen_string_literal: true

module Mixins::CanBeSent
  extend ActiveSupport::Concern

  included do
    def sent?
      self.sent_at.present?
    end

    def not_sent?
      !sent?
    end
  end
end
