class Overseers::WarehousesController < Overseers::BaseController
  before_action :set_company, only: [:edit,:show,:update]

  def index
    #@warehouses = ApplyDatatableParams.to(Warehouse.all, params)
    service = Services::Overseers::Finders::Warehouses.new(params)
    service.call
    @indexed_warehouses = service.indexed_records
    @warehouses = service.records
    authorize @warehouses
  end

  def new
    @warehouses = Warehouse.new
    authorize @warehouses
  end

  def create
    # @address = @company.addresses.build(address_params.merge(overseer: current_overseer))
    @warehouses = Warehouse.new(warehouse_params)
    authorize @warehouses

    if @warehouses.save
      redirect_to overseers_warehouse_path(@warehouses), notice: flash_message(@warehouses, action_name)
      # render 'show'
    else
        puts warehouse_params
    end

  end
  def edit
    authorize @warehouses
  end



  def update
    @warehouses.assign_attributes(warehouse_params)
    authorize @warehouses


    if @warehouses.save
      redirect_to overseers_warehouse_path(@warehouses), notice: flash_message(@warehouses, action_name)
    else
      render 'edit'
    end
  end

  # def autocomplete
  #   @warehouses = ApplyParams.to(Warehouse.all, params)
  #   authorize @warehouses
  # end

  def show
    authorize @warehouses
  end

  private

  def warehouse_params
    params.require(:warehouse).permit(
        :name
    )
  end
  def set_company
    @warehouses ||= Warehouse.find(params[:id])
  end

end
