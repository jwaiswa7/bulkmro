class Overseers::BrandPolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_cataloging?
  end
end
