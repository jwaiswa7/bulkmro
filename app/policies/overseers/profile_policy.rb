

class Overseers::ProfilePolicy < Overseers::ApplicationPolicy
  def edit?
    true
  end

  def update?
    edit?
  end
end
