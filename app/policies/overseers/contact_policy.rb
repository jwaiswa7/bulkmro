class Overseers::ContactPolicy < Overseers::ApplicationPolicy
  def become?
    true
  end

  def new?
    cataloging? || admin?
  end

end