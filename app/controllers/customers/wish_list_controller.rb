class Customers::WishListController < Customers::BaseController
    before_action :set_cart

    def show
      authorize @wish_list
    end

    private 

    def set_cart
      @wish_list = current_wish_list
    end
end