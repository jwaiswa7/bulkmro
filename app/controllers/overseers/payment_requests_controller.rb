class Overseers::PaymentRequestsController < Overseers::BaseController
  before_action :set_payment_request, only: [:show]

  def index
    payment_requests =
        if params[:status].present? || params[:owner].present?
          @param = params[:status] || params[:owner]
          if PaymentRequest.send(:valid_scope_name?, @param)
            PaymentRequest.send(@param)
          else
            PaymentRequest.where(status: @param)
          end
        else
          PaymentRequest.all
        end

    @payment_requests = ApplyDatatableParams.to(payment_requests.order(updated_at: :desc), params)
    authorize @payment_requests
    @statuses = payment_requests.group(:status).count
  end

  def update_payment_status
    @payment_requests = PaymentRequest.where(id: params[:payment_requests])
    authorize @payment_requests
    @payment_requests.update_all(status: params[:status_id].to_i)
  end

  def show
    authorize @payment_request
  end

  private

    def set_payment_request
      @payment_request = PaymentRequest.find(params[:id])
    end
end
