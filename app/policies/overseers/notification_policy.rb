# frozen_string_literal: true

class Overseers::NotificationPolicy < Overseers::ApplicationPolicy
  def mark_as_read?
    index?
  end

  def queue?
    index?
  end
end
