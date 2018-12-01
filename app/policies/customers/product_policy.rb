class Customers::ProductPolicy < Customers::ApplicationPolicy
  def most_ordered_products?
    true
  end

  def to_cart?
    true
  end
end