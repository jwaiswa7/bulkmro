class Overseers::DocumentCreationPolicy < Overseers::ApplicationPolicy
  def new?
    developer?
  end

  def create?
    new?
  end
end
