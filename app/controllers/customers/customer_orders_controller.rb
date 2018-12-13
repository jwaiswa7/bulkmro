class Customers::CustomerOrdersController < Customers::BaseController
  before_action :set_customer_order, only: [:show, :order_confirmed, :approve_order]

  def create
    authorize :customer_order

    @customer_order = current_contact.customer_orders.build(
        billing_address_id: current_cart.billing_address_id,
        shipping_address_id: current_cart.shipping_address_id,
        po_reference: current_cart.po_reference
    )

    ActiveRecord::Base.transaction do
      @customer_order.save!

      if current_contact.account_manager?
        @customer_order.create_approval(contact: current_contact)
      end
      @customer_order = current_contact.customer_orders.create(:company => current_company)
      @customer_order.assign_attributes(
          billing_address_id: current_cart.billing_address_id,
          shipping_address_id: current_cart.shipping_address_id,
          po_reference: current_cart.po_reference
      )

      @customer_order.save

      current_cart.items.each do |cart_item|
        @customer_order.rows.where(product_id: cart_item.product_id).first_or_create do |row|
          row.customer_order_id = @customer_order.id
          row.quantity = cart_item.quantity
          row.customer_product = cart_item.customer_product
        end
      end
      current_cart.destroy
    end

    redirect_to order_confirmed_customers_customer_order_path(@customer_order)
  end

  def show
    authorize @customer_order
  end

  def pending
    customer_orders = CustomerOrder.not_approved
    authorize customer_orders
    @customer_orders = ApplyDatatableParams.to(customer_orders, params)
  end

  def approve_order
    authorize @customer_order
    if @customer_order.create_approval(contact: current_contact)
      redirect_to customers_customer_orders_path, notice: flash_message(@customer_order, action_name)
    end
  end

  def order_confirmed
    authorize @customer_order
    if @customer_order.not_approved?
      render :template => 'customers/customer_orders/approval_pending'
    else
      render :template => 'customers/customer_orders/order_confirmed'
    end
  end

  def index
    @customer_orders = if current_contact.account_manager?
                         CustomerOrder.where(contact_id: current_contact.account.contact_ids).approved
                       else
                         current_contact.customer_orders.approved
                       end
    @customer_orders = ApplyDatatableParams.to(@customer_orders, params)
    authorize @customer_orders
  end

  private

  def set_customer_order
    @customer_order = current_contact.customer_orders.find(params[:id])
  end
end
