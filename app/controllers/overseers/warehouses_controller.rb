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
    @warehouse = Warehouse.new
    authorize @warehouse
  end

  def create
    @warehouse = Warehouse.new(warehouse_params)
    authorize @warehouse
    if @warehouse.save
      redirect_to overseers_warehouse_path(@warehouse), notice: flash_message(@warehouse, action_name)
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
        :name,
        :address_attributes => [:id,:street1,:street2,:country_code,:address_state_id,:city_name,:pincode]
    )
  end

  def set_company
    @warehouse ||= Warehouse.find(params[:id])
  end

end
