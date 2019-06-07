class Overseers::Companies::AddressesController < Overseers::Companies::BaseController
  before_action :set_address, only: [:show, :edit, :update]

  def index
    base_filter = {
        base_filter_key: 'company_id',
        base_filter_value: params[:company_id]
    }
    authorize :address
    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::Addresses.new(params.merge(base_filter), current_overseer)
        service.call
        @indexed_addresses = service.indexed_records
        @addresses = service.records.try(:reverse)
      end
    end
  end

  def autocomplete
    @addresses = ApplyParams.to(@company.addresses, params)
    authorize @addresses
  end

  def show
    authorize @address
  end

  def new
    @address = @company.addresses.build(overseer: current_overseer)
    authorize @address
  end


  def create
    @address = @company.addresses.build(address_params.merge(overseer: current_overseer))
    authorize @address
    @address.remove_gst_whitespace

    if @address.save
      @company.update_attributes(default_billing_address: @address) if @company.default_billing_address.blank?
      @company.update_attributes(default_shipping_address: @address) if @company.default_shipping_address.blank?
      @company.save_and_sync
      redirect_to overseers_company_path(@company), notice: flash_message(@address, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @address
  end

  def update
    @address.assign_attributes(address_params.merge(overseer: current_overseer))
    authorize @address
    @address.remove_gst_whitespace

    if @address.save
      @company.update_attributes(default_billing_address: @address) if @company.default_billing_address.blank?
      @company.update_attributes(default_shipping_address: @address) if @company.default_shipping_address.blank?
      @company.save_and_sync
      redirect_to overseers_company_path(@company), notice: flash_message(@address, action_name)
    else
      render 'edit'
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
          :remote_uid,
          :address_state_id,
          :state_name,
          :street1,
          :street2,
          :is_sez,
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
          :excise,
          :gst_type,
        :company_id
    )
  end
end
