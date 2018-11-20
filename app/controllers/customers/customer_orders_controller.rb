class Customers::CustomerOrdersController < Customers::BaseController
  before_action :set_customer_order, only: [:show, :order_confirmed, :approve_order]

  def create
    authorize :customer_order

    ActiveRecord::Base.transaction do
      if params[:page] == "edit_cart"
        current_cart.assign_attributes(cart_params)
        current_cart.save
      end
      @customer_order = current_contact.customer_orders.create
      if current_contact.account_manager?
        @customer_order.assign_attributes(status: "approved")
      else
        @customer_order.assign_attributes(status: "pending")
      end
      @customer_order.save
      current_cart.items.each do |cart_item|
        @customer_order.rows.where(product_id: cart_item.product_id).first_or_create do |row|
          row.customer_order_id = @customer_order.id
          row.quantity = cart_item.quantity
        end
      end
      current_cart.destroy
    end

    redirect_to order_confirmed_customers_customer_order_path(@customer_order)
  end

  def show
    authorize @customer_order
  end

  def pending_orders
    authorize :customer_order
    @customer_orders = ApplyDatatableParams.to(CustomerOrder.where(status: "pending"), params)
  end

  def approve_order
    authorize @customer_order
    @customer_order.update_columns(status: "approved")
    redirect_to customers_customer_orders_path
  end

  def order_confirmed
    authorize @customer_order
  end

  def index
    @customer_orders = ApplyDatatableParams.to(current_contact.customer_orders.where(status: "approved"), params)
    authorize @customer_orders
  end

  private

  def set_customer_order
    @customer_order = current_contact.customer_orders.find(params[:id])
  end

  def cart_params
    params.require(:cart).permit(items_attributes: [:quantity,:id])
  end
end
