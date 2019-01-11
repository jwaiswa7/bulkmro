class Overseers::AccountCreationRequestsController < Overseers::BaseController

  def index
    # company_que = AccountCreationRequest.where.not(:id => Account.pluck(:account_creation_request_id))
    account_que = AccountCreationRequest.all
    @account_creation_requests =   ApplyDatatableParams.to(account_que, params)
    authorize @account_creation_requests
  end
end
