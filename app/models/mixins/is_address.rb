module Mixins::IsAddress
  extend ActiveSupport::Concern

  included do
    after_initialize :set_is_address_defaults, :if => :new_record?
    def set_is_address_defaults
    end
  end
end