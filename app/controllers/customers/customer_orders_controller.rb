class Customers::CustomerOrdersController < Customers::BaseController
  before_action :set_customer_order, only: [:show, :order_confirmed]

  def create
    authorize :customer_order

    if params[:cart].present? && current_cart.id == params[:cart][:id].to_i
      payment = OnlinePayment.where(payment_id: params[:razorpay_payment_id]).first_or_create! do |online_payment|
        online_payment.assign_attributes(contact: current_customers_contact, payment_id: params[:razorpay_payment_id], auth_token: params[:authenticity_token], amount: params[:cart][:grand_total], metadata: params.to_json, status: :'created')
      end
      payment.save!
    end

    @customer_order = current_customers_contact.customer_orders.build(
      billing_address_id: current_cart.billing_address_id,
      shipping_address_id: current_cart.shipping_address_id,
      po_reference: current_cart.po_reference,
      special_instructions: current_cart.special_instructions,
      customer_po_sheet: (current_cart.customer_po_sheet.attached?) ? current_cart.customer_po_sheet.blob : nil
    )

    ActiveRecord::Base.transaction do
      @customer_order = current_customers_contact.customer_orders.create(company: current_company)
      @customer_order.assign_attributes(
        billing_address_id: current_cart.billing_address_id,
        shipping_address_id: current_cart.shipping_address_id,
        po_reference: current_cart.po_reference,
        special_instructions: current_cart.special_instructions,
        payment_method: current_cart.payment_method,
        customer_po_sheet: (current_cart.customer_po_sheet.attached?) ? current_cart.customer_po_sheet.attachment.blob : nil,
        calculated_total: current_cart.calculated_total,
        calculated_total_tax: current_cart.calculated_total_tax,
        grand_total: current_cart.grand_total
      )
      @customer_order.save
      @customer_order.update_attributes(online_order_number: Services::Resources::Shared::UidGenerator.online_order_number(@customer_order.id))

      Services::Customers::CustomerOrders::Approval.new(current_customers_contact, current_cart, current_company, @customer_order).call

      current_cart.items.each do |cart_item|
        @customer_order.rows.where(product_id: cart_item.product_id).first_or_create do |row|
          row.customer_order_id = @customer_order.id
          row.quantity = cart_item.quantity
          row.customer_product = cart_item.customer_product
          row.tax_rate_id = cart_item.customer_product.best_tax_rate.id
          row.tax_code_id = cart_item.customer_product.best_tax_code.id
        end
      end

      if payment.present?
        payment.update_attributes!(customer_order: @customer_order)
        payment.capture
      end

      current_cart.destroy
    end

    email_service = Services::Overseers::EmailMessages::SalesMailer.new(@customer_order, current_overseer)
    email_service.send_order_confirmation_email

    account_managers = @customer_order.company.contacts.where(role: 'account_manager')
    if account_managers.present?
      email_service.send_order_approval_email(account_managers)
    end

    redirect_to order_confirmed_customers_customer_order_path(@customer_order)
  end

  def show
    authorize @customer_order
  end

  def pending
    customer_orders = if current_customers_contact.account_manager?
      CustomerOrder.not_approved.not_rejected.where(contact_id: current_customers_contact.account.contact_ids)
    else
      current_customers_contact.customer_orders.not_approved.not_rejected
    end.order(id: :desc)

    authorize customer_orders
    @customer_orders = ApplyDatatableParams.to(customer_orders, params)
    render 'customers/customer_orders/index'
  end

  def approved
    customer_orders = if current_customers_contact.account_manager?
      CustomerOrder.approved.where(contact_id: current_customers_contact.account.contact_ids)
    else
      current_customers_contact.customer_orders.approved
    end.order(id: :desc)

    authorize customer_orders
    @customer_orders = ApplyDatatableParams.to(customer_orders, params)
    render 'customers/customer_orders/index'
  end

  def order_confirmed
    authorize @customer_order
    if @customer_order.not_approved?
      render template: 'customers/customer_orders/approval_pending'
    else
      render template: 'customers/customer_orders/order_confirmed'
    end
  end

  def index
    @customer_orders = if current_customers_contact.account_manager?
      CustomerOrder.where(contact_id: current_customers_contact.account.contact_ids)
    else
      current_customers_contact.customer_orders
    end.order(id: :desc)
    @customer_orders = ApplyDatatableParams.to(@customer_orders, params)
    authorize @customer_orders
  end

  def generate_punchout_order
    Services::Customers::CustomerOrders::GeneratePunchoutOrder.new(current_customers_contact, current_cart, current_company).call
    sign_out
  end

  private

    def set_customer_order
      @customer_order = CustomerOrder.find(params[:id])
    end
end
