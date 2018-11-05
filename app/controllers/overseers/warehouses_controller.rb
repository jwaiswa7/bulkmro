class Overseers::WarehousesController < Overseers::BaseController
  before_action :set_company, only: [:edit,:show,:update]

  def index
    @warehouses = ApplyDatatableParams.to(Warehouse.all, params)
    authorize @warehouses
  end

  def new
    @warehouses = Warehouse.new
    authorize @warehouses
  end

  def create
    @warehouses = Warehouse.new(warehouse_params)
    authorize @warehouses

    if @warehouses.save
      redirect_to overseers_warehouse_path(@warehouses), notice: flash_message(@warehouses, action_name)
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

  def show
    authorize @warehouses
  end

  private

  def warehouse_params
    params.require(:warehouse).permit(
        :name,
        :address_attributes => [:id,:street1,:street2,:country_code,:address_state_id,:city_name,:pincode]
    )
  end

  def set_company
    @warehouses ||= Warehouse.find(params[:id])
  end

end
