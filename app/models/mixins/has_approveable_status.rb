# frozen_string_literal: true

module Mixins::HasApproveableStatus
  extend ActiveSupport::Concern

  included do
    def status
      if approved?
        :approved
      elsif rejected?
        :rejected
      elsif defined?(:not_sent?) && not_sent?
        :draft
      elsif defined?(:sent?) && sent?
        :sent
      else
        :draft
      end
    end
  end
end
