class Overseers::AccountsController < Overseers::BaseController
  before_action :set_account, :only => [:edit, :update, :show]

  def index
    @accounts = ApplyDatatableParams.to(Account.all, params)
    authorize @accounts
  end

  def show
    authorize @account
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

  private

  def account_params
    params.require(:account).permit(
        :name, :alias,
        :contacts_attributes => [:id, :first_name, :last_name]
    )
  end

  def set_account
    @account = Account.find(params[:id])
  end
end