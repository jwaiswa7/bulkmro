class Customers::WishListItemsController < Customers::BaseController
    before_action :set_wish_list_item
    
    def destroy
        authorize @wish_list_item
        if @wish_list_item.destroy
          redirect_to customers_wish_list_path, notice: 'Item has been removed from the wish list'
        end
    end

    private 

    def set_wish_list_item
      @wish_list_item = WishListItem.find(params[:id])
    end
end
