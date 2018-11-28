class Overseers::CustomerOrderPolicy < Overseers::ApplicationPolicy
  def index?
    admin?
  end

  def view?
    admin?
  end

  def convert?
    admin?
  end
end