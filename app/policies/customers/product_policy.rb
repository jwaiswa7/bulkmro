class Customers::ProductPolicy < Customers::ApplicationPolicy
  def most_ordered_products?
    true
  end
end