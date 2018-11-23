class Overseers::CustomerProductPolicy < Overseers::ApplicationPolicy
  def generate_products?
    true
  end

  def remove_products?
    true
  end
end