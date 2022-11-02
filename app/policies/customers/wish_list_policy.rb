class Customers::WishListPolicy < Customers::ApplicationPolicy
    def show?
      true
    end
end