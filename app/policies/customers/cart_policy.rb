class Customers::CartPolicy < Customers::ApplicationPolicy
  def checkout?
    show?
  end
end