class Overseers::WarehousesController < Overseers::BaseController
  before_action :set_company, only: [:edit,:show,:update]

  def index
    @warehouses = ApplyDatatableParams.to(Warehouse.all, params)
    authorize @warehouses
  end

  def new
    @warehouse = Warehouse.new
    authorize @warehouse
  end

  def create
    # @address = @company.addresses.build(address_params.merge(overseer: current_overseer))
    @warehouse = Warehouse.new(warehouse_params)
    authorize @warehouse

    if @warehouse.save
      redirect_to overseers_warehouse_path(@warehouse), notice: flash_message(@warehouse, action_name)
      # render 'show'
    else
        puts warehouse_params
    end

  end
  def edit
    authorize @warehouse
  end



  def update
    @warehouse.assign_attributes(warehouse_params)
    authorize @warehouse


    if @warehouse.save
      redirect_to overseers_warehouse_path(@warehouse), notice: flash_message(@warehouse, action_name)
    else
      render 'edit'
    end
  end

  def show
    authorize @warehouse
  end

  private

  def warehouse_params
    params.require(:warehouse).permit(
        :name
    )
  end
  def set_company
    @warehouse ||= Warehouse.find(params[:id])
  end

end
