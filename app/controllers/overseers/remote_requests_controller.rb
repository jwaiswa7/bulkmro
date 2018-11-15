class Overseers::RemoteRequestsController < Overseers::BaseController
  before_action :set_remote_request, only: [:show]

  def index
    @remote_requests = ApplyDatatableParams.to(RemoteRequest.all, params)
    authorize @remote_requests
  end

  def show
    authorize @remote_request
    render json: JSON.pretty_generate({
        request: @remote_request.request,
        response: @remote_request.response
    })
  end

  private
  def set_remote_request
    @remote_request = RemoteRequest.find(params[:id])
  end
end