# frozen_string_literal: true

class Overseers::ResyncRemoteRequestPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || cataloging?
  end

  def show?
    admin? || cataloging?
  end

  def resend_failed_request?
    developer?
  end
end
