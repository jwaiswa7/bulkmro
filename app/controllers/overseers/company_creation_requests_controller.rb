class Overseers::CompanyCreationRequestsController < Overseers::BaseController
  def index
    @company_creation_requests =   ApplyDatatableParams.to(CompanyCreationRequest.all, params)
    authorize @company_creation_requests

  end
end
