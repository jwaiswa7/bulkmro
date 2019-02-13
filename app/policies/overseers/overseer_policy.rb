class Overseers::OverseerPolicy < Overseers::ApplicationPolicy
  def index?
    admin? || hr?
  end

  def edit?
    (admin? || hr?) && record != overseer
  end
end
