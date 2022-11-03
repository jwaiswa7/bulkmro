class Customers::WishListController < Customers::BaseController
    before_action :set_wish_list
    skip_before_action :verify_authenticity_token, only: :add_item

    def show
      authorize @wish_list
      @items = @wish_list.items.includes(:product)
    end

    def add_item
        authorize @wish_list
        product_id = params[:product_id]
        if @wish_list.items.where(product_id: product_id).empty?
          @item = @wish_list.items.new(product_id: params[:product_id])
          @item.save!
        end
    end

    private 

    def set_wish_list 
      @wish_list = current_wish_list
    end
end