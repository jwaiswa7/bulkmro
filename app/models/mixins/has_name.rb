module Mixins::HasName
  extend ActiveSupport::Concern

  included do
    def full_name
      [first_name, last_name].compact.join(' ')
    end
  end
end