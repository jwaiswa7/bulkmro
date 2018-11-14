class Customers::CartItemsController < Customers::BaseController
  before_action :set_cart_item, only: [:destroy]

  def create
    @cart_item = current_cart.items.where(:product_id => params[:product_id]).first_or_initialize do |cart_item|
      cart_item.quantity = params[:quantity]
    end

    authorize @cart_item

    if @cart_item.save
      respond_to do |format|
        format.js {}
      end
    end
  end

  def destroy
    authorize @cart_item

    if @cart_item.destroy
      respond_to do |format|
        format.html {redirect_to customers_products_path, notice: flash_message(@cart_item, action_name)}
        format.js {render :layout => false}
      end
    end
  end

  private
  def set_cart_item
    @cart_item = current_cart.items.find(params[:id])
  end
end