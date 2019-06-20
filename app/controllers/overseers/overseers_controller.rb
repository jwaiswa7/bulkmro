class Overseers::OverseersController < Overseers::BaseController
  before_action :set_overseer, only: [:edit, :update, :add_password_form, :update_password]

  def index
    # service = Services::Overseers::Finders::Overseers.new(params)
    # service.call
    # @indexed_overseers = service.indexed_records
    # @overseers = service.records
    @overseers = ApplyDatatableParams.to(Overseer.all, params)
    authorize @overseers
  end

  def new
    @overseer = Overseer.new(overseer: current_overseer)
    authorize @overseer
  end

  def create
    password = Devise.friendly_token[0, 20]
    @overseer = Overseer.new(overseer_params.merge(overseer: current_overseer, password: password, password_confirmation: password))
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
    @overseer.assign_attributes(overseer_params.merge(overseer: current_overseer).reject! {|k, v| (k == 'password' || k == 'password_confirmation') && v.blank?})

    if @overseer.save_and_sync
      if params[:overseer].present?
        redirect_to overseers_overseers_path, notice: flash_message(@overseer, action_name)
      end
    else
      render 'edit'
    end
    authorize @overseer
  end

  def add_password_form
    authorize @overseer
  end

  def update_password
    authorize @overseer
    @overseer.assign_attributes(overseer_password_params.merge(overseer: current_overseer, changed_by: current_overseer, changed_at: DateTime.now).reject! {|k, v| (k == 'password' || k == 'password_confirmation') && v.blank?})
    if @overseer.save!
      redirect_to overseers_overseers_path, notice: flash_message(@overseer, action_name)
    else
      render 'add_password_form'
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
        :updated_at
          # :password,
          # :password_confirmation,
          # :changed_at,
          # :changed_by

    )
  end

  def overseer_password_params
    params.require(:overseer).permit(
        :password,
        :password_confirmation,
        :changed_by,
        :changed_at
    )
  end

  def set_overseer
    @overseer = Overseer.find(params[:id])
  end
end
