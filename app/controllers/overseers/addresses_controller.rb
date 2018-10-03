class Overseers::AddressesController < Overseers::BaseController

  def index
    @addresses = ApplyDatatableParams.to(Address.all, params)
    authorize @addresses
  end

end