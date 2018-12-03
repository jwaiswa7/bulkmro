class Customers::CustomerProductPolicy < Customers::ApplicationPolicy
  def generate_all?
    true
  end

  def to_cart?
    true
  end
end