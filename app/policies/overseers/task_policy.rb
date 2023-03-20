class Overseers::TaskPolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def edit?
    record.status != "Completed"
  end

  def show?
    true
  end


end
