class Overseers::WarehousesController < Overseers::BaseController
  before_action :set_company, only: [:show]

  def index
    @warehouses = ApplyDatatableParams.to(Warehouse.all, params)
    authorize @warehouses
  end

  # def autocomplete
  #   @warehouses = ApplyParams.to(Warehouse.all, params)
  #   authorize @warehouses
  # end
=begin
  def show
    authorize @company
  end
=end
  private
  def set_company
    @company ||= Warehouse.find(params[:id])
  end

end
