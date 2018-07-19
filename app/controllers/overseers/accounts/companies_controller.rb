class Overseers::Accounts::CompaniesController < Overseers::Accounts::BaseController
  before_action :set_company, only: [:edit, :update]

  def new
    @company = @account.companies.build(overseer: current_overseer)
    authorize @company
  end

  def create
    @company = @account.companies.build(company_params.merge(overseer: current_overseer))
    authorize @company

    if @company.save
      redirect_to overseers_account_path(@account), notice: flash_message(@company, action_name)
    else
      render :new
    end
  end

  def edit
    authorize @company
  end

  def update
    @company.assign_attributes(company_params.merge(overseer: current_overseer))
    authorize @company

    if @company.save
      redirect_to overseers_account_path(@account), notice: flash_message(@company, action_name)
    else
      render :new
    end
  end

  private
  def set_company
    @company ||= Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(
        :account_id,
        :name,
        :default_payment_option_id,
        :contact_ids => [],
        :brand_ids => [],
        :product_ids => []
    )
  end
end
