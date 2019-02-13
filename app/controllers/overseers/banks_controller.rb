

class Overseers::BanksController < Overseers::BaseController
  before_action :set_bank, only: [:show, :edit, :update]

  def index
    service = Services::Overseers::Finders::Banks.new(params)
    service.call
    @indexed_banks = service.indexed_records
    @banks = service.records
    authorize @banks
  end

  def autocomplete
    @banks = ApplyParams.to(Bank.all, params)
    authorize @banks
  end

  def show
    authorize @bank
  end

  def new
    @bank = Bank.new
    authorize @bank
  end

  def create
    @bank = Bank.new(bank_params)
    authorize @bank

    if @bank.save_and_sync
      redirect_to overseers_banks_path, notice: flash_message(@bank, action_name)
    else
      render "new"
    end
  end

  def edit
    authorize @bank
  end

  def update
    @bank.assign_attributes(bank_params)
    authorize @bank

    if @bank.save_and_sync
      redirect_to overseers_bank_path(@bank), notice: flash_message(@bank, action_name)
    else
      render "edit"
    end
  end

  private

    def set_bank
      @bank ||= Bank.find(params[:id])
    end

    def bank_params
      params.require(:bank).permit(
        :country_code,
          :name,
          :code,
          :swift_number,
          :iban
      )
    end
end
