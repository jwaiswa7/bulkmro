class Overseers::DocumentCreationPolicy < Overseers::ApplicationPolicy
  def new?
    developer?
  end
end
