class Overseers::ActivitiesController < Overseers::BaseController
  before_action :set_activity, only: [:edit, :update]

  def index
    @activities = ApplyDatatableParams.to(Activity.all.includes(:created_by, :overseers), params)
    authorize @activities
  end

  def new
    @activity = current_overseer.activities.build(:overseer => current_overseer)
    @activity.build_company_creation_request
    @accounts = Account.all
    authorize @activity
  end

  def create
    @activity = Activity.new(activity_params.merge(overseer: current_overseer))
    company_creation_request = @activity.company_creation_request
    if @activity.company_id.present?
      company_creation_request.destroy!
    end
    if company_creation_request.account_id.present?
      company_creation_request.account_name = nil
      company_creation_request.account_type =nil
    end
    authorize @activity
    if @activity.save
      redirect_to overseers_activities_path, notice: flash_message(@activity, action_name)
    else
      render 'new'
    end
  end

  def edit
    @activity.build_company_creation_request if @activity.company_creation_request.nil?
    authorize @activity
  end

  def update
    @activity.assign_attributes(activity_params.merge(overseer: current_overseer))
    if @activity.company_id.present?
      company_creation_request.destroy!
    end
    if company_creation_request.account_id.present?
      company_creation_request.account_name = nil
      company_creation_request.account_type =nil
    end
    authorize @activity
    if @activity.save
      redirect_to overseers_activities_path, notice: flash_message(@activity, action_name)
    end
  end

  private
  def activity_params
    params.require(:activity).permit(
        :inquiry_id,
        :company_id,
        :contact_id,
        :company_type,
        :subject,
        :purpose,
        :activity_type,
        :points_discussed,
        :actions_required,
        :overseer_ids => [],
        :company_creation_request_attributes => [
            :name,
            :email,
            :first_name,
            :last_name,
            :address,
            :account_id,
            :account_type,
            :account_name


          ]
    )
  end

  def set_activity
    @activity = Activity.find(params[:id])
  end
end
