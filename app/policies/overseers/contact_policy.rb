class Overseers::ContactPolicy < Overseers::ApplicationPolicy
  def become?
    cataloging? || admin? || manager?
  end

  def new?
    cataloging? || admin?
  end

end