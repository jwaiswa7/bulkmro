class Overseers::AnnualTargetsController < Overseers::BaseController
  before_action :set_target, only: [:show, :edit, :update, :destroy]

  def index
    @annual_targets = ApplyDatatableParams.to(AnnualTarget.all, params)
    authorize :annual_target
  end

  def show
    authorize @annual_target
  end

  def new
    if params[:overseer_id].present?
      @overseer = Overseer.find(params[:overseer_id])
      @annual_target = @overseer.annual_targets.build(overseer: current_overseer)
    else
      @annual_target = AnnualTarget.new(overseer: current_overseer)
    end
    authorize @annual_target
  end

  def edit
    authorize @annual_target
  end

  def create
    @overseer = Overseer.find(annual_target_params[:overseer_id])
    @annual_target = @overseer.annual_targets.build(annual_target_params.merge(overseer: current_overseer))
    authorize @annual_target

    if @annual_target.save
      service = Services::Overseers::Targets::CreateMonthlyTargets.new(@overseer, @annual_target)
      service.call
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
