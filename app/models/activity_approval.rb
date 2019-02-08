# frozen_string_literal: true

class ActivityApproval < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :activity
end
