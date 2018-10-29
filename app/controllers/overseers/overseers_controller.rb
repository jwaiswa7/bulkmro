class Overseers::OverseersController < Overseers::BaseController
  before_action :set_overseer, only: [:edit, :update]

  def index
    service = Services::Overseers::Finders::Overseers.new(params)
    service.call
    @indexed_Overseers = service.indexed_records
    @overseers = service.records
    authorize @overseers
  end

  def new
    @overseer = Overseer.new(overseer: current_overseer)
    authorize @overseer
  end

  def create
    @overseer = Overseer.new(overseer_params.merge(overseer: current_overseer))
    authorize @overseer
    if @overseer.save_and_sync
      redirect_to overseers_overseers_path, notice: flash_message(@overseer, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @overseer
  end

  def update
    @overseer.assign_attributes(overseer_params.merge(overseer: current_overseer).reject! { |_, v| v.blank? })
    authorize @overseer
    if @overseer.save_and_sync
      redirect_to overseers_overseers_path, notice: flash_message(@overseer, action_name)
    else
      render 'edit'
    end
  end

  private
  def overseer_params
    params.require(:overseer).permit(
        :first_name,
        :last_name,
        :role,
        :parent_id,
        :email,
        :mobile,
        :telephone,
        :identifier,
        :designation,
        :department,
        :function,
        :geography,
        :status,
        :password,
        :password_confirmation,
    )
  end

  def set_overseer
    @overseer = Overseer.find(params[:id])
  end
end
