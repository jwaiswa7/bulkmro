class Overseers::Companies::CompanyBanksController < Overseers::Companies::BaseController
  before_action :set_company_bank, only: [:show, :edit, :update]

  def index
    base_filter = {
        base_filter_key: 'company_id',
        base_filter_value: params[:company_id]
    }
    authorize_acl :company_bank
    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::CompanyBanks.new(params.merge(base_filter))
        service.call
        @indexed_company_banks = service.indexed_records
        @company_banks = service.records.try(:reverse)
      end
    end
  end

  def autocomplete
    @company_banks = ApplyParams.to(@company.company_banks, params)
    authorize_acl @company_banks
  end

  def show
    authorize_acl @company_bank
  end

  def new
    @company = Company.find(params[:company_id])
    @company_bank = @company.company_banks.build
    authorize_acl @company_bank
  end

  def create
    @company = Company.find(params[:company_id])
    ifsc_code_number = company_bank_params['ifsc_code_number'].split().first if company_bank_params['ifsc_code_number'].present?
    ifsc = IfscCode.find(company_bank_params['ifsc_code_id'])
    @company_bank = @company.company_banks.build(company_bank_params.except('ifsc_code_id', 'ifsc_code_number'))
    @company_bank.ifsc_code = ifsc
    @company_bank.ifsc_code_number = ifsc_code_number
    authorize_acl @company_bank
    if @company_bank.save_and_sync
      redirect_to overseers_company_path(@company), notice: flash_message(@company_bank, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize_acl @company_bank
  end

  def update
    ifsc_code_number = company_bank_params['ifsc_code_number'].split().first if company_bank_params['ifsc_code_number'].present?
    ifsc = IfscCode.find(company_bank_params['ifsc_code_id'])
    @company_bank.assign_attributes(company_bank_params.except('ifsc_code_id', 'ifsc_code_number'))
    @company_bank.ifsc_code = ifsc
    @company_bank.ifsc_code_number = ifsc_code_number
    authorize_acl @company_bank

    if @company_bank.save_and_sync
      redirect_to overseers_company_company_bank_path(@company, @company_bank), notice: flash_message(@company_bank, action_name)
    else
      render 'edit'
    end
  end

  private

    def set_company_bank
      @company_bank ||= CompanyBank.find(params[:id])
    end

    def company_bank_params
      params.require(:company_bank).permit(
        :company_id,
          :bank_id,
          :branch,
          :account_name,
          :account_number,
          :address_line_1,
          :address_line_2,
          :beneficiary_email,
          :beneficiary_mobile,
          :mandate_id,
          :account_number_confirmation,
          :ifsc_code_number,
          :ifsc_code_id,
          attachments: []
      )
    end
end
