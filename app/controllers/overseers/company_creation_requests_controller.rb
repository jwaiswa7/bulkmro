class Overseers::CompanyCreationRequestsController < Overseers::BaseController
  before_action :set_company_creation_request, only: [:show]

  def requested
    @company_creation_requests =   ApplyDatatableParams.to( CompanyCreationRequest.all.requested.order(id: :desc), params)
    authorize @company_creation_requests
    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def created
    @company_creation_requests =   ApplyDatatableParams.to( CompanyCreationRequest.all.created.order(id: :desc), params)
    authorize @company_creation_requests
    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def index
    @company_creation_requests =   ApplyDatatableParams.to( CompanyCreationRequest.all.order(id: :desc), params)
    authorize @company_creation_requests
  end

  def show
    authorize @company_creation_request
  end

  private

  def set_company_creation_request
    @company_creation_request ||= CompanyCreationRequest.find(params[:id])
  end
end
