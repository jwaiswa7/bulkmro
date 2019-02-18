# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :sender, class_name: 'Overseer'
  belongs_to :recipient, class_name: 'Overseer'

  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(6) }

  after_commit -> { NotificationRelayJob.perform_later(self) }
end
