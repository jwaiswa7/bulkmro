class Overseers::RemoteRequestPolicy < Overseers::ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end
end