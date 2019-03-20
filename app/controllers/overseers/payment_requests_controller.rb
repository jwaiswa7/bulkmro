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

  def show
    authorize @payment_request
  end

  private

    def set_payment_request
      @payment_request = PaymentRequest.find(params[:id])
    end
end
