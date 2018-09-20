class Overseers::OverseerPolicy < Overseers::ApplicationPolicy
  def index?
    admin?
  end
end