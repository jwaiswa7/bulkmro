class Overseers::CompanyCreationRequestsController < Overseers::BaseController
  before_action :set_company_creation_request, only: [:show, :exchange_with_existing_company]

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

  def exchange_with_existing_company
    authorize @company_creation_request
    company = Company.where(:id => params[:company_id]).last
    activity = @company_creation_request.activity
    activity.company_id = params[:company_id]
    activity.account = company.account
    activity.save
    @company_creation_request.account =company.account
    @company_creation_request.company = company
    @company_creation_request.save
    redirect_to overseers_company_creation_request_path(@company_creation_request), notice: flash_message(@company_creation_request, action_name)

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
