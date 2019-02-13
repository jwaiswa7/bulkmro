

class ActivityRejection < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :activity
end
