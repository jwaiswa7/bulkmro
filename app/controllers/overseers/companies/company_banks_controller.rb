class Overseers::Companies::CompanyBanksController < Overseers::Companies::BaseController
  before_action :set_company_bank, only: [:show, :edit, :update, :destroy]

  # GET /company_banks
  # GET /company_banks.json
  def index
    @company_banks = CompanyBank.all
  end

  # GET /company_banks/1
  # GET /company_banks/1.json
  def show
  end

  # GET /company_banks/new
  def new
    @company_bank = CompanyBank.new
  end

  # GET /company_banks/1/edit
  def edit
  end

  # POST /company_banks
  # POST /company_banks.json
  def create
    @company_bank = CompanyBank.new(company_bank_params)

    respond_to do |format|
      if @company_bank.save
        format.html { redirect_to @company_bank, notice: 'Company bank was successfully created.' }
        format.json { render :show, status: :created, location: @company_bank }
      else
        format.html { render :new }
        format.json { render json: @company_bank.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /company_banks/1
  # PATCH/PUT /company_banks/1.json
  def update
    respond_to do |format|
      if @company_bank.update(company_bank_params)
        format.html { redirect_to @company_bank, notice: 'Company bank was successfully updated.' }
        format.json { render :show, status: :ok, location: @company_bank }
      else
        format.html { render :edit }
        format.json { render json: @company_bank.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /company_banks/1
  # DELETE /company_banks/1.json
  def destroy
    @company_bank.destroy
    respond_to do |format|
      format.html { redirect_to company_banks_url, notice: 'Company bank was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company_bank
      @company_bank = CompanyBank.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_bank_params
      params.fetch(:company_bank, {})
    end
end
