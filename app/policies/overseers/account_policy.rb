class Overseers::AccountPolicy < Overseers::ApplicationPolicy
  def new?
    super && !sales?
  end
end