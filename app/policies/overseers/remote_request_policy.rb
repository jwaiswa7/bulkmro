class Overseers::RemoteRequestPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || cataloging?
  end

  def show?
    admin? || cataloging?
  end
end