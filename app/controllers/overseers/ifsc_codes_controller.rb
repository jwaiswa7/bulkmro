class Overseers::IfscCodesController < Overseers::BaseController
  before_action :set_ifsc_code, only: [:show, :edit, :update]

  def index
    service = Services::Overseers::Finders::IfscCodes.new(params)
    service.call

    @indexed_ifsc_codes = service.indexed_records
    @ifsc_codes = service.records

    authorize @ifsc_codes
  end

  def new
    @ifsc_code = IfscCode.new
    authorize @ifsc_code
  end

  def create
    @ifsc_code = IfscCode.new(ifsc_code_params)
    authorize @ifsc_code

    if @ifsc_code.save
      redirect_to overseers_ifsc_codes_path, notice: flash_message(@ifsc_code, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @ifsc_code
  end

  def update
    @ifsc_code.assign_attributes(ifsc_code_params)
    authorize @ifsc_code
    if @ifsc_code.save
      redirect_to overseers_ifsc_codes_path, notice: flash_message(@ifsc_code, action_name)
    else
      render 'new'
    end
  end

  def show
    authorize @ifsc_code
  end

  def suggestion
    authorize :ifsc_code
    service = Services::Overseers::Finders::IfscCodes.new(params)
    service.call

    indexed_records = service.indexed_records
    ifsc_codes = []
    indexed_records.each do |record|
      ifsc_codes << record.attributes
    end

    render json: {ifsc_codes: ifsc_codes}.to_json
  end

  private

    def ifsc_code_params
      params.require(:ifsc_code).permit(
        :id,
        :ifsc_code,
        :branch,
        :address,
        :city,
        :state,
        :district,
        :contact,
        :bank_id
      )
    end

    def set_ifsc_code
      @ifsc_code = IfscCode.find(params[:id])
    end
end
