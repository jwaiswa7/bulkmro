class Overseers::AccountPolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging? || logistics?
  end
end