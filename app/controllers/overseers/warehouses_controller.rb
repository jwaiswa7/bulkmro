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

  def show
    authorize @warehouses
  end

  private
  def set_company
    @warehouses ||= Warehouse.find(params[:id])
  end

end
