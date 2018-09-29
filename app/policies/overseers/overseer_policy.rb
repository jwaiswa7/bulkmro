class Overseers::OverseerPolicy < Overseers::ApplicationPolicy
  def index?
    admin?
  end

  def edit?
    admin? || record == overseer
  end
end