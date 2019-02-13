

class Overseers::DocPolicy < Overseers::ApplicationPolicy
  def index
    admin?
  end
end
