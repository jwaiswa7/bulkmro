# frozen_string_literal: true

class Overseers::NotificationsController < Overseers::BaseController
  def index
    @notifications = ApplyDatatableParams.to(Notification.where(recipient: current_overseer), params)
    authorize @notifications
  end

  def queue
    @notifications = Notification.where(recipient: current_overseer).recent
    authorize @notifications
  end

  def mark_as_read
    @notifications = Notification.where(recipient: current_overseer).unread
    @notifications.update_all(read_at: Time.zone.now)
    authorize @notifications
    render json: { success: true }
  end
end
