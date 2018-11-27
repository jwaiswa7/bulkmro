module Mixins::CanBeActivated
  extend ActiveSupport::Concern

  included do

    scope :active, -> { where(is_active:  true) }

    def active
      self.is_active?
    end

  end
end