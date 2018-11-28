class Overseers::CustomerProductPolicy < Overseers::ApplicationPolicy
  def generate_catalog?
    admin?
  end

  def destroy_all?
    admin?
  end
end