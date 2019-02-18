# frozen_string_literal: true

class Overseers::MeasurementUnitsController < Overseers::BaseController
  before_action :set_measurement_unit, only: %i[edit update show]

  def autocomplete
    @measurement_units = ApplyParams.to(MeasurementUnit.all, params).order(:name)
    authorize @measurement_units
  end

  def index
    @measurement_units = ApplyDatatableParams.to(MeasurementUnit.all, params)
    authorize @measurement_units
  end

  def show
    redirect_to overseers_measurement_units_edit_path(@measurement_unit)
    authorize @measurement_unit
  end

  def new
    @measurement_unit = MeasurementUnit.new
    authorize @measurement_unit
  end

  def create
    @measurement_unit = MeasurementUnit.new(measurement_unit_params)
    authorize @measurement_unit

    if @measurement_unit.save
      redirect_to overseers_measurement_units_path, notice: flash_message(@measurement_unit, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @measurement_unit
  end

  def update
    @measurement_unit.assign_attributes(measurement_unit_params)
    authorize @measurement_unit

    if @measurement_unit.save
      redirect_to overseers_measurement_units_path, notice: flash_message(@measurement_unit, action_name)
    else
      render 'edit'
    end
  end

  private

    def set_measurement_unit
      @measurement_unit ||= MeasurementUnit.find(params[:id])
    end

    def measurement_unit_params
      params.require(:measurement_unit).permit(
        :name
      )
    end
end
