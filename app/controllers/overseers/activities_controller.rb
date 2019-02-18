# frozen_string_literal: true

class Overseers::ActivitiesController < Overseers::BaseController
  before_action :set_activity, only: %i[edit update]

  def index
    @activities = ApplyDatatableParams.to(Activity.all.includes(:created_by, :overseers), params)
    authorize @activities
  end

  def new
    @activity = current_overseer.activities.build(overseer: current_overseer)
    authorize @activity
  end

  def create
    @activity = Activity.new(activity_params.merge(overseer: current_overseer))
    authorize @activity
    if @activity.save
      redirect_to overseers_activities_path, notice: flash_message(@activity, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @activity
  end

  def update
    @activity.assign_attributes(activity_params.merge(overseer: current_overseer))
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
        overseer_ids: []
      )
    end

    def set_activity
      @activity = Activity.find(params[:id])
    end
end
