class Overseers::CompanyCreationRequestsController < Overseers::BaseController
  before_action :set_company_creation_request, only: [:show]

  def index
    company_que = CompanyCreationRequest.includes(:company).where(companies:  { id: nil })
    @company_creation_requests =   ApplyDatatableParams.to(company_que, params)
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
