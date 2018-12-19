module Mixins::CanBeActivated
  extend ActiveSupport::Concern

  included do

    scope :active, -> { where(is_active:  true) }

  end
end