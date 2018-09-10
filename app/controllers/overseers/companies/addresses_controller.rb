class Overseers::Companies::AddressesController < Overseers::Companies::BaseController
  before_action :set_address, only: [:edit, :update]

  def new
    @address = @company.addresses.build(overseer: current_overseer)
    authorize @address
  end

  def create
    @address = @company.addresses.build(address_params.merge(overseer: current_overseer))
    authorize @address

    if @address.save
      redirect_to overseers_company_path(@company), notice: flash_message(@address, action_name)
    else
      render :new
    end
  end

  def edit
    authorize @address
  end

  def update
    @address.assign_attributes(address_params.merge(overseer: current_overseer))
    authorize @address

    if @address.save
      redirect_to overseers_company_path(@company), notice: flash_message(@address, action_name)
    else
      render :new
    end
  end

  private
  def set_address
    @address ||= Address.find(params[:id])
  end

  def address_params
    params.require(:address).permit(
        :name,
        :country_code,
        :pincode,
        :city_name,
        :address_state_id,
        :state_name,
        :street1,
        :street2,
        :telephone,
        :mobile,
        :gst_proof,
        :cst_proof,
        :vat_proof,
        :excise_proof,
        :gst,
        :cst,
        :vat,
        :tan,
        :excise
    )
  end
end
