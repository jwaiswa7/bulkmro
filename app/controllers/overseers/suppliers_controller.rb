

class Overseers::SuppliersController < Overseers::BaseController
  def index
    @suppliers = ApplyParams.to(Company.all, params)
    authorize @suppliers
  end

  def autocomplete
    @suppliers = ApplyParams.to(Company.acts_as_supplier, params)
    authorize @suppliers
  end
end
