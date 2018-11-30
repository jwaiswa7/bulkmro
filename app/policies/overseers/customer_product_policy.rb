class Overseers::CustomerProductPolicy < Overseers::ApplicationPolicy
  def generate_catalog?
    developer?
  end

  def destroy_all?
    developer?
  end
end