class Overseers::AccountsController < Overseers::BaseController
  before_action :set_account, :only => [:edit, :update, :show]

  def index
    @accounts = ApplyDatatableParams.to(Account.all, params)
    authorize @accounts
  end

  def show
    if (@account.is_customer?)
      service = ['Services', 'Overseers', 'Reports', 'Account'].join('::').constantize.send(:new, @account, params)
      @data = service.call
    end

    authorize @account
  end

  def autocomplete
    @accounts = ApplyParams.to(Account.all, params)
    authorize @accounts
  end

  def new
    @account = Account.new(overseer: current_overseer)
    if params[:ccr_id].present?
      requested_account = CompanyCreationRequest.where(:id => params[:ccr_id]).last
      if !requested_account.nil?
        @account = Account.new({'name': requested_account.account_name,'account_type': requested_account.account_type, 'reference_company_creation_request_id': params[:ccr_id]}.merge(overseer: current_overseer))
      end
    end
    authorize @account
  end

  def create
    @account = Account.new(account_params.merge(overseer: current_overseer))
    authorize @account

    if @account.alias.blank?
      @account.alias = @account.name
    end

    if @account.save
      company_creation_request = CompanyCreationRequest.where(:id => @account.reference_company_creation_request_id).last
      if !company_creation_request.nil?
        company_creation_request.account_id = @account.id
        company_creation_request.save
        activity = company_creation_request.activity
        activity.account = @account
        activity.save
      end
      if @account.save_and_sync
        redirect_to overseers_account_path(@account), notice: flash_message(@account, action_name)
      end
    else
      render 'new'
    end
  end

  def edit
    authorize @account
  end

  def update
    @account.assign_attributes(account_params.merge(overseer: current_overseer))
    authorize @account

    if @account.alias.blank?
      @account.alias = @account.name
    end

    if @account.save_and_sync
      redirect_to overseers_account_path(@account), notice: flash_message(@account, action_name)
    else
      render 'edit'
    end
  end

  private

  def account_params
    params.require(:account).permit(
        :name,
        :alias,
        :account_type,
        :reference_company_creation_request_id
    )
  end

  def set_account
    @account = Account.find(params[:id])
  end
end