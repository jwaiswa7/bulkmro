# frozen_string_literal: true

class Customers::CartItemsController < Customers::BaseController
  before_action :set_cart_item, only: [:destroy]
  before_action :cart_item_params, only: [:create]

  def create
    authorize :cart_item

    @cart_item = current_cart.items.where(product_id: cart_item_params[:product_id], customer_product_id: cart_item_params[:customer_product_id]).first_or_create

    @cart_item.update_attributes(quantity: cart_item_params[:quantity])

    respond_to do |format|
      format.js { }
    end
  end

  def update
    authorize :cart_item
  end

  def destroy
    authorize @cart_item

    if @cart_item.destroy
      respond_to do |format|
        format.html { redirect_to customers_cart_path(current_cart), notice: flash_message(@cart_item, action_name) }
        format.js { render layout: false }
      end
    end
  end

  private

    def set_cart_item
      @cart_item = current_cart.items.find(params[:id])
    end

    def cart_item_params
      params.require(:cart_item).permit(:quantity, :product_id, :customer_product_id)
    end
end
