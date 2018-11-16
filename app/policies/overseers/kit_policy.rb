class Overseers::KitPolicy < Overseers::ApplicationPolicy
  def index?
    admin?
  end

end