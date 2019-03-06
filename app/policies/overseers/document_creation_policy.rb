class Overseers::DocumentCreationPolicy < Overseers::ApplicationPolicy
  def new?
    manager_or_sales? || logistics?
  end

  def create?
    new?
  end
end
