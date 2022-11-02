class Customers::WishListController < Customers::BaseController
    before_action :set_cart
    skip_before_action :verify_authenticity_token, only: :add_item

    def show
      authorize @wish_list
    end

    def add_item
        authorize @wish_list
    end

    private 

    def set_cart
      @wish_list = current_wish_list
    end
end