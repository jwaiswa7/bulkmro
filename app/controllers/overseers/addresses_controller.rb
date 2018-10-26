class Overseers::AddressesController < Overseers::BaseController

  def index
    @addresses = ApplyDatatableParams.to(Address.all, params)
    authorize @addresses
  end

  def autocomplete
    account = Account.find(params[:account_id]) if params[:account_id].present?
    company = Company.find(params[:company_id]) if params[:company_id].present?
    addresses = (account || company).addresses

    @addresses = ApplyParams.to(addresses.includes(:state), params)
    authorize @addresses
  end
end