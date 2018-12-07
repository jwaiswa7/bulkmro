class Customers::CustomerProductPolicy < Customers::ApplicationPolicy
  def generate_all?
    true
  end

  def most_ordered_products?
    true
  end
end