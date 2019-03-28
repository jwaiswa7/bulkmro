class Overseers::PaymentRequestsController < Overseers::BaseController
  before_action :set_payment_request, only: [:show]

  def index
    service = Services::Overseers::Finders::PaymentRequests.new(params, current_overseer)
    service.call

    @indexed_payment_requests = service.indexed_records
    @payment_requests = service.records


    authorize :payment_request
    status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_payment_requests, PaymentRequest)
    status_service.call

    @total_values = status_service.indexed_total_values
    @statuses = status_service.indexed_statuses
  end

  def update_payment_status
    @payment_requests = PaymentRequest.where(id: params[:payment_requests])
    authorize @payment_requests
    @payment_requests.update_all(status: params[:status_id].to_i)
    @payment_requests.each do |payment_request|
      payment_comment = PaymentRequestComment.new(message: "Status Changed:#{PaymentRequest.statuses.invert[params[:status_id].to_i]}", payment_request: payment_request, overseer: current_overseer)
      payment_comment.save
    end
  end

  def show
    authorize @payment_request
  end

  private

    def set_payment_request
      @payment_request = PaymentRequest.find(params[:id])
    end
end
