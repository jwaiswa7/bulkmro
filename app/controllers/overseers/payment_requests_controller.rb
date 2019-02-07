class Overseers::PaymentRequestsController < Overseers::BaseController
  before_action :set_payment_request, only: [:show]

  def index
    payment_requests =
        if params[:status].present? || params[:owner].present?
          @param = params[:status] || params[:owner]
          if PaymentRequest.send(:valid_scope_name?, @param)
            PaymentRequest.send(@param)
          else
            PaymentRequest.where(:status => @param)
          end
        else
          PaymentRequest.all
        end

    @payment_requests = ApplyDatatableParams.to(payment_requests.order(due_date: :desc), params)
    authorize @payment_requests
    @statuses = payment_requests.group(:status).count
  end

  def show
    authorize @payment_request
  end

  private

  def set_payment_request
    @payment_request = PaymentRequest.find(params[:id])
  end
end
