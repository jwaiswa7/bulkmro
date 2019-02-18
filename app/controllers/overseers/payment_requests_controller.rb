# frozen_string_literal: true

class Overseers::PaymentRequestsController < Overseers::BaseController
  before_action :set_payment_request, only: [:show]

  def index
    payment_requests =
      if params[:status].present?
        @status = params[:status]
        PaymentRequest.where(status: params[:status])
      else
        PaymentRequest.all
      end.order(id: :desc)

    @payment_requests = ApplyDatatableParams.to(payment_requests, params, paginate: false)
    authorize @payment_requests
    @statuses = @payment_requests.pluck(:status)
  end

  def show
    authorize @payment_request
  end

  private

    def set_payment_request
      @payment_request = PaymentRequest.find(params[:id])
    end
end
