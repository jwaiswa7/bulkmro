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
    render json: { gst_code: @address_state.gst_code }
  end
end
