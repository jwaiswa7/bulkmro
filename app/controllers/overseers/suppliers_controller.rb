class Overseers::SuppliersController < Overseers::BaseController

  def index
    @suppliers = ApplyParams.to(Company.all, params)
    authorize @suppliers
  end

end
