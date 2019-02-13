class ActivityApproval < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :activity
end
