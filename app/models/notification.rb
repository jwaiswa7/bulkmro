class Notification < ApplicationRecord
  belongs_to :overseer
  belongs_to :recipient, class_name: "Overseer"

  belongs_to :notifiable, polymorphic: true

  scope :unread, ->{ where(read_at: nil) }
  scope :recent, ->{ order(created_at: :desc).limit(6) }

  after_commit -> { NotificationRelayJob.perform_later(self) }

  def notifiable_url
    [action, notifiable_type].join('')
  end
end
