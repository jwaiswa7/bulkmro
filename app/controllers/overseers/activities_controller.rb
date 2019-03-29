class Overseers::ActivitiesController < Overseers::BaseController
  before_action :set_activity, only: [:edit, :update, :approve, :reject]

  def index
    service = Services::Overseers::Finders::Activities.new(params)
    service.call

    @indexed_activities = service.indexed_records
    @activities = service.records
    authorize @activities
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
    authorize @activities
  end


  def new
    @activity = current_overseer.activities.build(overseer: current_overseer)
    @activity.build_company_creation_request(overseer: current_overseer)
    @activity.build_contact_creation_request(overseer: current_overseer)
    @accounts = Account.all
    authorize @activity
  end

  def create
    @activity = Activity.new(activity_params.merge(overseer: current_overseer))
    company_creation_params = activity_params['company_creation_request_attributes']
    if company_creation_params['create_new_contact'] == 'true'
      @activity.build_contact_creation_request(
        overseer: current_overseer,
        email: company_creation_params['email'],
        first_name: company_creation_params['first_name'],
        last_name: company_creation_params['last_name'],
        telephone: company_creation_params['telephone'],
        mobile_number: company_creation_params['mobile_number']
      )
    end
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
      @activity.create_approval(overseer: current_overseer)
      ActivitiesIndex::Activity.import([@activity.id])
    end
    redirect_to overseers_activities_path, notice: flash_message(@activity, action_name)
  end

  def approve_selected
    @activities = Activity.where(id: params[:activities])

    authorize @activities
    @activities.each do |activity|
      ActiveRecord::Base.transaction do
        activity.create_approval(overseer: current_overseer)
        ActivitiesIndex::Activity.import([activity.id])
      end
    end
  end

  def reject_selected
    @activities = Activity.where(id: params[:activities])

    authorize @activities
    @activities.each do |activity|
      ActiveRecord::Base.transaction do
        activity.create_rejection(overseer: current_overseer)
        ActivitiesIndex::Activity.import([activity.id])
      end
    end
  end

  def reject
    authorize @activity
    ActiveRecord::Base.transaction do
      @activity.create_rejection(overseer: current_overseer)
      ActivitiesIndex::Activity.import([@activity.id])
    end
    redirect_to overseers_activities_path, notice: flash_message(@activity, action_name)
  end

  def add_to_inquiry
    @activities = Activity.where(id: params[:activities])
    @inquiry = params[:inquiry]

    authorize @activities
    @activities.update_all(inquiry_id: @inquiry)
  end

  def export_all
    authorize :activity
    service = Services::Overseers::Exporters::ActivitiesExporter.new(params[:q], current_overseer, [])
    service.call

    redirect_to url_for(Export.activities.not_filtered.last.report)
  end


  def export_filtered_records
    authorize :activity

    service = Services::Overseers::Finders::Activities.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::ActivitiesExporter.new(nil, current_overseer, service.records.pluck(:id))
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
            :telephone,
            :mobile_number,
            :activity_id,
            :create_new_contact
        ],
        contact_creation_request_attributes: [
            :first_name,
            :last_name,
            :email,
            :phone_number,
            :mobile_number,
            :activity_id
        ],
        attachments: []
      )
    end

    def set_activity
      @activity = Activity.find(params[:id])
    end
end
