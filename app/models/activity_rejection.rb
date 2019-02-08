# frozen_string_literal: true

class ActivityRejection < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :activity
end
