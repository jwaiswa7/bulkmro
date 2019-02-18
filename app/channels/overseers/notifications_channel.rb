# frozen_string_literal: true

class Overseers::NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications:#{current_overseer.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
