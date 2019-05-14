class Overseers::ActivitiesController < Overseers::BaseController
  before_action :set_activity, only: [:edit, :update, :approve, :reject]

  def index
    service = Services::Overseers::Finders::Activities.new(params)
    service.call

    @indexed_activities = service.indexed_records
    @activities = service.records
    authorize_acl @activities
  end

  def pending
    # @activities = ApplyDatatableParams.to(Activity.all.includes(:created_by, :overseers).not_approved.not_rejected, params)
    #
    base_filter = {
        base_filter_key: 'approval_status',
        base_filter_value: 'pending'
    }

    service = Services::Overseers::Finders::Activities.new(params.merge(base_filter))
    service.call
    @indexed_activities = service.indexed_records
    @activities = service.records
    authorize_acl @activities
  end


  def new
    @activity = current_overseer.activities.build(overseer: current_overseer)
    @activity.build_company_creation_request(overseer: current_overseer)
    @accounts = Account.all
    authorize_acl @activity
  end

  def create
    @activity = Activity.new(activity_params.merge(overseer: current_overseer))
    authorize_acl @activity
    if @activity.save
      redirect_to pending_overseers_activities_path, notice: flash_message(@activity, action_name)
    else
      render 'new'
    end
  end

  def edit
    @activity.build_company_creation_request if @activity.company_creation_request.nil?
    authorize_acl @activity
  end

  def update
    @activity.assign_attributes(activity_params.merge(overseer: current_overseer))
    company_creation_request = @activity.company_creation_request

    authorize_acl @activity
    if @activity.save
      redirect_to pending_overseers_activities_path, notice: flash_message(@activity, action_name)
    end
  end

  def approve
    authorize_acl @activity
    ActiveRecord::Base.transaction do
      @activity.create_approval(overseer: current_overseer)
      ActivitiesIndex::Activity.import([@activity.id])
    end
    redirect_to overseers_activities_path, notice: flash_message(@activity, action_name)
  end

  def approve_selected
    @activities = Activity.where(id: params[:activities])

    authorize_acl @activities
    @activities.each do |activity|
      ActiveRecord::Base.transaction do
        activity.create_approval(overseer: current_overseer)
        ActivitiesIndex::Activity.import([activity.id])
      end
    end
  end

  def reject_selected
    @activities = Activity.where(id: params[:activities])

    authorize_acl @activities
    @activities.each do |activity|
      ActiveRecord::Base.transaction do
        activity.create_rejection(overseer: current_overseer)
        ActivitiesIndex::Activity.import([activity.id])
      end
    end
  end

  def reject
    authorize_acl @activity
    ActiveRecord::Base.transaction do
      @activity.create_rejection(overseer: current_overseer)
      ActivitiesIndex::Activity.import([@activity.id])
    end
    redirect_to overseers_activities_path, notice: flash_message(@activity, action_name)
  end

  def add_to_inquiry
    @activities = Activity.where(id: params[:activities])
    @inquiry = params[:inquiry]

    authorize_acl @activities
    @activities.update_all(inquiry_id: @inquiry)
  end

  def export_all
    authorize_acl :activity
    service = Services::Overseers::Exporters::ActivitiesExporter.new(params[:q], current_overseer, [])
    service.call

    redirect_to url_for(Export.activities.not_filtered.last.report)
  end


  def export_filtered_records
    authorize_acl :activity

    service = Services::Overseers::Finders::Activities.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::ActivitiesExporter.new(nil, current_overseer, service.records)
    export_service.call
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
          :activity_date,
          :activity_type,
          :points_discussed,
          :actions_required,
          :expenses,
          overseer_ids: [],
          company_creation_request_attributes: [
              :name,
              :email,
              :first_name,
              :last_name,
              :address,
              :account_type,
          ],
          attachments: []
      )
    end

    def set_activity
      @activity = Activity.find(params[:id])
    end
end
