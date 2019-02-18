# frozen_string_literal: true

class CallbackRequest < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::IsARequest

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.hits = 0
  end
end
