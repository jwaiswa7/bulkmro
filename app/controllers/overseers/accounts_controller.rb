class Overseers::AccountsController < Overseers::BaseController
  before_action :set_account, :only => [:edit, :update]
  def index
    @accounts = Account.all
    authorize @accounts
  end

  def new
    @account = Account.new
    authorize @account
  end

  def create
    @account = Account.new(account_params)
    authorize @account
    if @account.save
      set_flash(@account, action_name)
      redirect_to edit_overseers_account_path(@account)
    else
      render 'new'
    end
  end

  def edit
    authorize @account
  end

  def update
    @account.assign_attributes(account_params)
    authorize @account
    if @account.save
      set_flash(@account, action_name)
      redirect_to edit_overseers_account_path(@account)
    end
  end

  private
  def account_params
    params.require(:account).permit(
      :id,
      :name,
      :contacts_attributes => [:id, :first_name, :last_name]
    )
  end

  def set_account
    @account = Account.find(params[:id])
  end
end