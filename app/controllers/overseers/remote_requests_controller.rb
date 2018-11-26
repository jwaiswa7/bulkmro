class Overseers::RemoteRequestsController < Overseers::BaseController
  before_action :set_remote_request, only: [:show]

  def index
    @remote_requests = ApplyDatatableParams.to(RemoteRequest.all, params)
    authorize @remote_requests
  end

  def show
    authorize @remote_request
    render :show
  end

  def latest_status(request)
    RemoteRequest.where(:subject_type => request.subject_type).where(:subject_id => request.subject_id).order(:created_at).first.status
  end

  private
  def set_remote_request
    @remote_request = RemoteRequest.find(params[:id])
  end
end