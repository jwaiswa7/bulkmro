class Quote < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
end
