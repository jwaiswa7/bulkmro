class Customers::CustomerOrdersController < Customers::BaseController
  before_action :set_customer_order, only: [:show, :order_confirmed]

  def create
    authorize :customer_order

    ActiveRecord::Base.transaction do
      @customer_order = current_contact.customer_orders.create
      @customer_order.assign_attributes(billing_address_id: current_cart.billing_address_id,
                                        shipping_address_id: current_cart.shipping_address_id,
                                        po_reference: current_cart.po_reference)
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

  def order_confirmed
    authorize @customer_order
  end

  def index
    @customer_orders = ApplyDatatableParams.to(current_contact.customer_orders, params)
    authorize @customer_orders
  end

  private

  def set_customer_order
    @customer_order = current_contact.customer_orders.find(params[:id])
  end
end
