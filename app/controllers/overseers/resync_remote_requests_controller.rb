class Overseers::ResyncRemoteRequestsController < Overseers::BaseController
  before_action :set_resync_remote_request, only: [:show, :resend_failed_request]

  def index
    @remote_requests = ApplyDatatableParams.to(ResyncRemoteRequest.all.order(id: :desc), params)
    authorize @remote_requests
  end

  def show
    authorize @remote_request
    render :show
  end

  def resend_failed_request
    authorize :resync_remote_request
    resync_service = Services::Resources::Shared::ResyncFailedRequests.new(@remote_request)
    resync_service.call

    redirect_to overseers_resync_remote_requests_path
  end

  private
    def set_resync_remote_request
      @remote_request = ResyncRemoteRequest.find(params[:id])
    end
end
