class Overseers::AnnualTargetsController < Overseers::BaseController
  before_action :set_target, only: [:show, :edit, :update, :destroy]
  before_action :set_overseer, only: [:show, :edit, :update, :destroy]
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def index
    @annual_targets = ApplyDatatableParams.to(AnnualTarget.all, params)
    authorize :annual_target
  end

  def show
    if @annual_target.overseer.present?
      @targets = @overseer.annual_targets.last.targets if @overseer.targets.present?
    elsif @annual_target.account.present?
      @targets = @account.annual_targets.last.account_targets if @account.account_targets.present?
    end
    authorize @annual_target
  end

  def new
    if params[:overseer_id].present?
      @overseer = Overseer.find(params[:overseer_id])
      @annual_target = @overseer.annual_targets.build(overseer: current_overseer)
    elsif params[:account_id].present?
      @account = Account.find(params[:account_id])
      @annual_target = @account.annual_targets.build
    end
    authorize_acl @annual_target
  end

  def edit
    authorize_acl @annual_target
  end

  def create
    if annual_target_params[:overseer_id].present?
      overseer = Overseer.find(annual_target_params[:overseer_id])
      annual_target = overseer.annual_targets.build(annual_target_params.merge(resource_id: account.id, resource_type: 1))
    elsif annual_target_params[:account_id].present?
      account = Account.find(annual_target_params[:account_id])
      annual_target = account.annual_targets.build(annual_target_params.merge(resource_id: account.id, resource_type: 2))
    end
    authorize_acl annual_target

    if annual_target.save
      if overseer.present?
        service = Services::Overseers::Targets::CreateMonthlyTargets.new(overseer, annual_target)
        service.call
        redirect_to overseers_overseer_path(overseer), notice: 'Annual Target was successfully created.'
      elsif account.present?
        service = Services::Overseers::Targets::CreateAccountMonthlyTargets.new(account, annual_target)
        service.call
        redirect_to overseers_accounts_path, notice: 'Annual Target was successfully created.'
      end

    else
      render :new
    end
  end

  def update
    authorize_acl @annual_target
    if @annual_target.update(annual_target_params)
      redirect_to overseers_overseer_path(@overseer), notice: 'Annual Target was successfully updated.'
    else
      render :edit
    end
  end

  private

    def set_target
      @annual_target = AnnualTarget.find(params[:id])
    end

    def set_overseer
      @overseer = @annual_target.overseer if @annual_target.resource_type == 'Overseer'
    end

    def set_account
      @account = @annual_target.account if @annual_target.resource_type == 'Account'
    end

    def annual_target_params
      params.require(:annual_target).permit(
          :overseer_id,
          :account_id,
        :manager_id,
        :business_head_id,
        :year,
        :inquiry_target,
        :account_target,
        :resource_id,
        :resource_type
    )
  end
end
