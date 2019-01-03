class Overseers::Companies::CompanyBanksController < Overseers::Companies::BaseController
  before_action :set_company_bank, only: [:show, :edit, :update, :destroy]

  def index
    @company_banks = ApplyDatatableParams.to(@company.banks, params)
    authorize @company_banks
  end

  def autocomplete
    @company_banks = ApplyParams.to(@company.company_banks, params)
    authorize @company_banks
  end

  def show
    authorize @company_bank
  end

  def new
    @company = Company.find(params[:company_id])
    @company_bank = @company.banks.build
    authorize @company_bank
  end

  def create
    @company = Company.find(params[:company_id])
    @company_bank = @company.banks.build(company_bank_params)
    authorize @company_bank

    if @company_bank.save
      redirect_to overseers_company_path(@company), notice: flash_message(@company_bank, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @company_bank
  end

  def update
    @company_bank.assign_attributes(company_bank_params)
    authorize @company_bank

    if @company_bank.save
      redirect_to overseers_company_company_bank_path(@company, @company_bank), notice: flash_message(@company_bank, action_name)
    else
      render 'edit'
    end
  end

  def destroy
    authorize @company_bank
    @company_bank.destroy!

    redirect_to overseers_company_path(@company)
  end

  private

  def set_company_bank
    @company_bank ||= CompanyBank.find(params[:id])
  end

  def company_bank_params
    params.require(:company_bank).permit(
        :company_id,
        :country_code,
        :name,
        :code,
        :branch,
        :ifsc_code,
        :account_name,
        :account_number,
        :address_line_1,
        :address_line_2,
        :beneficiary_email,
        :beneficiary_mobile
    )
  end
end