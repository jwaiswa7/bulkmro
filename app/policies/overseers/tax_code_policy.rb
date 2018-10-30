class Overseers::TaxCodePolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging?
  end
end