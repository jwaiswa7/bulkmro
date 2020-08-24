class Overseers::AddressesController < Overseers::BaseController
  def index
    service = Services::Overseers::Finders::Addresses.new(params)
    service.call

    @indexed_addresses = service.indexed_records
    @addresses = service.records

    authorize_acl :address
  end

  def autocomplete
    account = Account.find(params[:account_id]) if params[:account_id].present?
    company = Company.find(params[:company_id]) if params[:company_id].present?
    addresses = (account || company).addresses

    @addresses = ApplyParams.to(addresses.includes(:state), params)
    authorize_acl @addresses
  end

  def warehouse_addresses
    addresses = Address.joins(:warehouse)
    @addresses = ApplyParams.to(addresses.includes(:state), params)
    authorize_acl @addresses
    render 'autocomplete'
  end

    def is_sez_params
    @addresses = Address.find(params[:address_id])
    render json: { is_sez: @addresses.is_sez}.to_json
    authorize_acl @addresses
  end


  def get_gst_code
    authorize_acl :address
    @address_state = AddressState.indian.find(params[:state_id])
    # Daman and Diu gst code changed in august 2020 from 25 to 26, we have to keep previous gst for existing data
    if @address_state.id == 470 && Date.today <= Date.new(2020, 8, 21)
      @gst_code = 25
    else
      @gst_code = @address_state.gst_code
    end
    render json: { gst_code: @gst_code }
  end
end
