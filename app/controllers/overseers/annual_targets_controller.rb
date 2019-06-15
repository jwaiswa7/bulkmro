class Overseers::AnnualTargetsController < Overseers::BaseController
  before_action :set_target, only: [:show, :edit, :update, :destroy]

  def index
    @annual_targets = AnnualTarget.all
    authorize :annual_target
  end

  def show
  end

  def new
    if params[:overseer_id].present?
      @overseer = Overseer.find(params[:overseer_id])
      @annual_target = AnnualTarget.new(overseer: @overseer)
    else
      @annual_target = AnnualTarget.new
    end
    authorize @annual_target
  end

  def edit
    authorize @annual_target
  end

  def create
    @overseer = Overseer.find(annual_target_params[:overseer_id])
    @annual_target = AnnualTarget.new(annual_target_params.merge(overseer: @overseer))
    authorize @annual_target

    if @annual_target.save
      redirect_to overseers_overseer_path(@overseer), notice: 'Annual Target was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @annual_target
    if @annual_target.update(annual_target_params)
      redirect_to overseers_overseer_path(@annual_target.overseer), notice: 'Annual Target was successfully created.'
    else
      render :edit
    end
  end

  private

  def set_target
    @annual_target = AnnualTarget.find(params[:id])
  end

  def annual_target_params
    params.require(:annual_target).permit(
        :overseer_id,
        :year,
        :inquiry_target,
        :company_target,
        :invoice_target,
        :invoice_margin_target,
        :order_target,
        :order_margin_target,
        :new_client_target
    )
  end
end
