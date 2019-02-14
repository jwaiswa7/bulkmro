class Overseers::AccountsController < Overseers::BaseController
  before_action :set_account, only: [:edit, :update, :show]

  def index
    @accounts = ApplyDatatableParams.to(Account.all, params)
    authorize @accounts
  end

  def show
    if @account.is_customer?
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
    authorize @account
  end

  def create
    @account = Account.new(account_params.merge(overseer: current_overseer))
    authorize @account

    if @account.alias.blank?
      @account.alias = @account.name
    end

    if @account.save_and_sync
      redirect_to overseers_account_path(@account), notice: flash_message(@account, action_name)
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

  def payment_collection
    @accounts = ApplyDatatableParams.to(Account.all, params)
    authorize :account
    service = Services::Overseers::SalesInvoices::PaymentDashboard.new()
    service.call
    @summery_data = service.summery_data
  end

  private

    def account_params
      params.require(:account).permit(
        :name,
          :alias,
          :account_type
      )
    end

    def set_account
      @account = Account.find(params[:id])
    end
end
