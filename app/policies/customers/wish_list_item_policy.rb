class Customers::WishListItemPolicy < Customers::ApplicationPolicy
  def destroy?
    true
  end

end
  