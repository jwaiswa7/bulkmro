# frozen_string_literal: true

class NotificationRelayJob < ApplicationJob
  queue_as :default

  def perform(notification)
    # html = ApplicationController.render partial: "notifications/#{notification.notifiable_type.underscore.pluralize}/#{notification.action}", locals: {notification: notification}, formats: [:html]
    html = ApplicationController.render partial: 'notifications/overseers/notifications', locals: { notification: notification }, formats: [:html]
    ActionCable.server.broadcast "notifications:#{notification.recipient.id}", html: html
  end
end
