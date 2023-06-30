# frozen_string_literal: true

class NotificationRelayJob < ApplicationJob
  queue_as :default

  # If record is no longer available, it is safe to ignore
  discard_on ActiveJob::DeserializationError

  discard_on ActiveRecord::RecordNotFound

  def perform(notification_id)
    notification = Notification.find(notification_id)
    # html = ApplicationController.render partial: "notifications/#{notification.notifiable_type.underscore.pluralize}/#{notification.action}", locals: {notification: notification}, formats: [:html]
    html = ApplicationController.render partial: 'notifications/overseers/notifications', locals: { notification: notification }, formats: [:html]
    ActionCable.server.broadcast "notifications:#{notification.recipient.id}", html: html
  end
end
