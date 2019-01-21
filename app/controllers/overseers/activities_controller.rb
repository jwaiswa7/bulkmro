class Overseers::ActivitiesController < Overseers::BaseController
  before_action :set_activity, only: [:edit, :update, :approve, :reject]

  def index
    @activities = ApplyDatatableParams.to(Activity.all.includes(:created_by, :overseers).approved, params)
    authorize @activities
  end

  def pending
    @activities = ApplyDatatableParams.to(Activity.all.includes(:created_by, :overseers).not_approved.not_rejected, params)
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

    authorize @activity
    if @activity.save
      redirect_to pending_overseers_activities_path, notice: flash_message(@activity, action_name)
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
    company_creation_request = @activity.company_creation_request

    authorize @activity
    if @activity.save
      redirect_to pending_overseers_activities_path, notice: flash_message(@activity, action_name)
    end
  end

  def approve
    authorize @activity
    ActiveRecord::Base.transaction do
      @activity.create_approval(:overseer => current_overseer)
    end
    redirect_to overseers_activities_path, notice: flash_message(@activity, action_name)
  end

  def approve_selected
    @activities = Activity.where(id: params[:activities])

    authorize @activities
    @activities.each do |activity|
      ActiveRecord::Base.transaction do
        activity.create_approval(:overseer => current_overseer)
      end
    end
  end

  def reject_selected

    @activities = Activity.where(id: params[:activities])

    authorize @activities
    @activities.each do |activity|
      ActiveRecord::Base.transaction do
        activity.create_rejection(:overseer => current_overseer)
      end
    end

  end

  def reject
    authorize @activity
    ActiveRecord::Base.transaction do
      @activity.create_rejection(:overseer => current_overseer)
    end
    redirect_to overseers_activities_path, notice: flash_message(@activity, action_name)
  end

  def add_to_inquiry

    @activities = Activity.where(id: params[:activities])
    @inquiry = params[:inquiry]

    authorize @activities
    @activities.update_all(inquiry_id: @inquiry)

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
