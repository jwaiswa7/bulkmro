class Customers::Companies::AddressesController < Customers::Companies::BaseController

  def autocomplete
    @addresses = ApplyParams.to(@company.addresses.includes(:state), params)
    authorize @addresses
  end

end