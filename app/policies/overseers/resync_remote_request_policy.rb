class Overseers::ResyncRemoteRequestPolicy < Overseers::ApplicationPolicy
  def index?
    admin?
  end

  def all_requests?
    admin?
  end

  def show?
    admin?
  end

  def resend_failed_request?
    developer?
  end
end
