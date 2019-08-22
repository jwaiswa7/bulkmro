class Overseers::CompanyCreationRequestsController < Overseers::BaseController
  before_action :set_company_creation_request, only: [:show, :update]

  def requested
    @company_creation_requests = ApplyDatatableParams.to(CompanyCreationRequest.all.requested.order(id: :desc), params)
    authorize_acl @company_creation_requests
    respond_to do |format|
      format.json { render 'index' }
      format.html { render 'index' }
    end
  end

  def created
    @company_creation_requests = ApplyDatatableParams.to(CompanyCreationRequest.all.created.order(id: :desc), params)
    authorize_acl @company_creation_requests
    respond_to do |format|
      format.json { render 'index' }
      format.html { render 'index' }
    end
  end

  def update
    authorize_acl @company_creation_request
    company = Company.where(id: params[:company_creation_request][:company_id]).last
    @company_creation_request.activity.update_attributes!(company_id: params[:company_id], account: company.account) if @company_creation_request.activity.present?
    @company_creation_request.update_attributes(account: company.account, company: company)
    redirect_to overseers_company_creation_request_path(@company_creation_request), notice: flash_message(@company_creation_request, action_name)
  end

  def index
    @company_creation_requests = ApplyDatatableParams.to(CompanyCreationRequest.all.order(id: :desc), params)
    authorize_acl @company_creation_requests
  end

  def show
    authorize_acl @company_creation_request
  end

  private

    def set_company_creation_request
      @company_creation_request ||= CompanyCreationRequest.find(params[:id])
    end
end
