class Overseers::CustomerOrdersController < Overseers::BaseController
  before_action :set_customer_order, only: [:show]

  def index
    @customer_orders = ApplyDatatableParams.to(CustomerOrder.all.order(id: :desc), params)
    authorize_acl @customer_orders
  end

  def payments
    payments = if params[:company_id].present?
      OnlinePayment.joins(:customer_order).where('customer_orders.company_id = ?', params[:company_id])
    else
      OnlinePayment.all
    end.order(id: :desc)
    @payments = ApplyDatatableParams.to(payments, params.except(:company_id))
    authorize_acl :customer_order
  end

  def refresh_payment
    authorize_acl :customer_order
    if params[:payment_id].present?
      payment = OnlinePayment.where(payment_id: params[:payment_id])
      if payment.present?
        payment.fetch_payment
      end
    end
    redirect_to payments_overseers_customer_orders_path
  end

  def show
    authorize_acl @customer_order
  end

  private
    def set_customer_order
      @customer_order = CustomerOrder.find(params[:id])
    end
end
