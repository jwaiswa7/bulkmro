class Overseers::CallbackRequestsController < Overseers::BaseController
  before_action :set_callback_request, only: [:show]

  def index
    service = Services::Overseers::Finders::CallbackRequests.new(params)
    service.call
    @indexed_callback_request = service.indexed_records
    @callback_requests = service.records
    authorize @callback_requests
  end

  def show
    authorize @callback_request
    render :show
  end

  private
  def set_callback_request
    @callback_request = CallbackRequest.find(params[:id])
  end
end