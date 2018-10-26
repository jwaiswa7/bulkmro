class Customers::CustomerOrdersController < Customers::BaseController

  def create
    @cart = current_cart
    ActiveRecord::Base.transaction do
      @customer_order = CustomerOrder.new(contact_id: params[:contact_id])
      @customer_order.save
      @cart.cart_items.each do |cart_item|
        customer_order = CustomerOrderRow.new(customer_order_id: @customer_order.id, product_id: cart_item.product_id, quantity: cart_item.quantity)
        customer_order.save
      end
    end

    if @customer_order.save
      session[:cart_id] = nil
      @cart.destroy
      redirect_to customers_customer_order_path(@customer_order)
    end
  end

  def show
    @customer_order = CustomerOrder.find(params[:id])
  end

end
