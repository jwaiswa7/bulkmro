

module Mixins::HasVisibility
  extend ActiveSupport::Concern

  included do
    after_initialize :set_has_visibility_defaults, if: :new_record?
    def set_has_visibility_defaults
      self.is_visible ||= true
    end

    scope :visible, -> { where(is_visible: true) }
    scope :not_visible, -> { where(is_visible: false) }
  end
end
