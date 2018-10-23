class Customers::CartItemsController < Customers::BaseController

  def create
    cart = current_cart
    product_id = params[:product_id].to_i
    quantity = params[:quantity].to_i

    if cart.cart_items.present?
      product_ids = cart.cart_items.map(&:product_id)
      if product_ids.include? product_id
        cart_item = CartItem.find_by(product_id: product_id)
        cart_item.quantity += 1
        cart_item.save
      else
        new_cart_item(cart, quantity, product_id)
      end
    else
      new_cart_item(cart, quantity, product_id)
    end

    session[:cart_id] = cart.id
    redirect_to customers_cart_path
  end

  def destroy
    @cart = current_cart
    @item = @cart.cart_items.find(params[:id])
    @item.destroy
    @cart.save
    redirect_to customers_cart_path
  end

  private

  def item_params
    params.require(:cart_item).permit(:quantity, :product_id)
  end

  def new_cart_item(cart, quantity, product_id)
    cart.cart_items.new(quantity: quantity, product_id: product_id)
    cart.save
  end
end