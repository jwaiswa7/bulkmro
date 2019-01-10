class Overseers::AddressesController < Overseers::BaseController

  def index
     service = Services::Overseers::Finders::Addresses.new(params)
     service.call

     @indexed_addresses = service.indexed_records
     @addresses = service.records

     authorize :address
  end

  def autocomplete
    account = Account.find(params[:account_id]) if params[:account_id].present?
    company = Company.find(params[:company_id]) if params[:company_id].present?
    addresses = (account || company).addresses

    @addresses = ApplyParams.to(addresses.includes(:state), params)
    authorize @addresses
  end

  def warehouse_addresses
    addresses = Address.joins(:warehouse)
    @addresses = ApplyParams.to(addresses.includes(:state), params)
    authorize @addresses
    render 'autocomplete'
  end

end