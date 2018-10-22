class Customers::CartItemsController < ApplicationController

  def new
  	debugger
  end
  
  def create
    @cart = current_cart
    @item = @cart.cart_items.new(item_params)
    @cart.save
    session[:cart_id] = @cart.id
    redirect_to customers_products_path
  end

  def destroy
    @cart = current_cart
    @item = @cart.cart_items.find(params[:id])
    @item.destroy
    @cart.save
    redirect_to cart_path
  end

  private

  def item_params
    params.require(:cart_item).permit(:quantity, :product_id)
  end


end