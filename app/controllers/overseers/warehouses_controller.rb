# frozen_string_literal: true

class Overseers::WarehousesController < Overseers::BaseController
  before_action :set_warehouse, only: [:edit, :show, :update]

  def index
    @warehouses = ApplyDatatableParams.to(Warehouse.all, params)
    authorize @warehouses
  end

  def new
    @warehouse = Warehouse.new
    authorize @warehouse
  end

  def autocomplete
    authorize :warehouse
    @warehouse = ApplyParams.to(Warehouse.all.active, params)
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
          :is_active,
          address_attributes: [:id, :street1, :street2, :country_code, :address_state_id, :city_name, :pincode],
      )
    end

    def set_warehouse
      @warehouse ||= Warehouse.find(params[:id])
    end
end
