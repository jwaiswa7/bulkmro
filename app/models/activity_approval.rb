class ActivityApproval < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :activity

  enum activity_status: {
      'Approved': 10,
      'Cancelled': 20
  }
end
