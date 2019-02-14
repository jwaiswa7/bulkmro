

class Customers::CustomerProductPolicy < Customers::ApplicationPolicy
  def generate_all?
    true
  end

  def most_ordered_products?
    contact.customer_products.exists?
  end

  def index?
    current_company.customer_products.exists?
  end

  def online_orders?
    contact.customer_products.exists?
  end
end
