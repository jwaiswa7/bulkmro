class Customers::CustomerProductPolicy < Customers::ApplicationPolicy
  def generate_all?
    true
  end
end