class Customers::WishListPolicy < Customers::ApplicationPolicy
    def show?
      true
    end

    def add_item?
        true
    end
end