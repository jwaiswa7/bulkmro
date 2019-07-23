class Overseers::WarehousesController < Overseers::BaseController
  before_action :set_warehouse, only: [:edit, :show, :update]

  def index
    @warehouses = ApplyDatatableParams.to(Warehouse.all, params)
    authorize_acl @warehouses
  end

  def new
    @warehouse = Warehouse.new
    authorize_acl @warehouse
  end

  def autocomplete
    authorize_acl :warehouse
    if params[:bill_from].present? && params[:bill_from] == true.to_s
      warehouses = Warehouse.where('is_active = ? AND series_code IS NOT ?', true, nil)
    else
      warehouses = Warehouse.all.active
    end
    @warehouse = ApplyParams.to(warehouses, params)
  end

  def series
    @serieses = ApplyDatatableParams.to(Series.all.order(document_type: :asc), params)
    authorize_acl :warehouse
  end

  def create
    @warehouse = Warehouse.new(warehouse_params)
    authorize_acl @warehouse
    if @warehouse.save
      redirect_to overseers_warehouse_path(@warehouse), notice: flash_message(@warehouse, action_name)
    else
      puts warehouse_params
    end
  end

  def edit
    authorize_acl @warehouse
  end

  def update
    @warehouse.assign_attributes(warehouse_params)
    authorize_acl @warehouse
    if @warehouse.save
      redirect_to overseers_warehouse_path(@warehouse), notice: flash_message(@warehouse, action_name)
    else
      render 'edit'
    end
  end

  def show
    authorize_acl @warehouse
  end

  private

    def warehouse_params
      params.require(:warehouse).permit(
        :name,
          :is_active,
          address_attributes: [:id, :street1, :street2, :country_code, :address_state_id, :city_name, :pincode],
      )
    end

    def set_warehouse
      @warehouse ||= Warehouse.find(params[:id])
    end
end
