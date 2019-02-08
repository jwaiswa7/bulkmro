# frozen_string_literal: true

class Overseers::Companies::CompanyBanksController < Overseers::Companies::BaseController
  before_action :set_company_bank, only: [:show, :edit, :update]

  def index
    base_filter = {
        base_filter_key: "company_id",
        base_filter_value: params[:company_id]
    }
    authorize :company_bank
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
    authorize @company_banks
  end

  def show
    authorize @company_bank
  end

  def new
    @company = Company.find(params[:company_id])
    @company_bank = @company.company_banks.build
    authorize @company_bank
  end

  def create
    @company = Company.find(params[:company_id])
    @company_bank = @company.company_banks.build(company_bank_params)
    authorize @company_bank

    if @company_bank.save_and_sync
      redirect_to overseers_company_path(@company), notice: flash_message(@company_bank, action_name)
    else
      render "new"
    end
  end

  def edit
    authorize @company_bank
  end

  def update
    @company_bank.assign_attributes(company_bank_params)
    authorize @company_bank

    if @company_bank.save_and_sync
      redirect_to overseers_company_company_bank_path(@company, @company_bank), notice: flash_message(@company_bank, action_name)
    else
      render "edit"
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
          :mandate_id
      )
    end
end
