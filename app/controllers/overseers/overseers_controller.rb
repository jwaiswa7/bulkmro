class Overseers::OverseersController < Overseers::BaseController
  before_action :set_overseer, only: [:show, :edit, :update, :save_acl_resources, :get_resources, :get_menu_resources, :edit_acl, :update_acl, :change_password, :update_password]

  def index
    # service = Services::Overseers::Finders::Overseers.new(params)
    # service.call
    # @indexed_overseers = service.indexed_records
    # @overseers = service.records
    @overseers = ApplyDatatableParams.to(Overseer.all, params)
    authorize_acl @overseers
  end

  def new
    @overseer = Overseer.new(overseer: current_overseer)
    authorize_acl @overseer
  end

  def create
    password = Devise.friendly_token[0, 20]
    @overseer = Overseer.new(overseer_params.merge(overseer: current_overseer, password: password, password_confirmation: password))
    authorize_acl @overseer
    if @overseer.save_and_sync
      redirect_to overseers_overseers_path, notice: flash_message(@overseer, action_name)
    else
      render 'new'
    end
  end

  def show
    @annual_targets = @overseer.annual_targets if @overseer.annual_targets.present?
    authorize_acl @overseer
  end

  def edit
    authorize_acl @overseer
  end

  def edit_acl
    authorize_acl @overseer
    # authorize_acl(:overseer, 'update_acl')
  end

  def update_acl
    authorize_acl :overseer
    begin
      acl_role = AclRole.find(params[:acl_role_id])
      if acl_role.present?
        checked_ids = params[:checked_ids]

        if params[:menu_checked_ids].present?
          checked_ids = checked_ids + params[:menu_checked_ids]
        end

        if Overseer.roles.keys.include? acl_role.role_name.underscore
          @overseer.update_attribute(:role, acl_role.role_name.underscore)
        end

        @overseer.update_attribute(:acl_resources, checked_ids.uniq.to_json)
        @overseer.update_attribute(:acl_role_id, acl_role.id)
        @overseer.update_attribute(:acl_updated_by, current_overseer.id)
        @overseer.update_attribute(:acl_updated_at, Time.now)

        render json: {success: 1, message: 'Updated successfully.'}
      else
        render json: {success: 0, message: 'Role not found.'}
      end
    rescue StandardError => e
      render json: {success: 0, message: e}
    end
  end

  def update
    @overseer.assign_attributes(overseer_params.merge(overseer: current_overseer).reject! {|k, v| (k == 'password' || k == 'password_confirmation') && v.blank?})

    authorize_acl @overseer
    if @overseer.save_and_sync
      # acl_role = AclRole.find(params[:overseer][:acl_role_id])
      # @overseer.update_attributes(:acl_resources => acl_role.role_resources) if acl_role.present?
      if params[:overseer].present?
        redirect_to overseers_overseers_path, notice: flash_message(@overseer, action_name)
      end
    else
      render 'edit'
    end
    authorize_acl @overseer
  end

  def change_password
    authorize_acl @overseer
  end

  def update_password
    authorize_acl @overseer
    @overseer.assign_attributes(overseer_password_params.merge(overseer: current_overseer, changed_by: current_overseer, changed_at: DateTime.now))
    if @overseer.save
      redirect_to overseers_overseers_path, notice: flash_message(@overseer, action_name)
    else
      render 'change_password'
    end
  end

  def get_resources
    default_resources = get_acl_resource_json
    current_acl = ActiveSupport::JSON.decode(@overseer.acl_resources)
    parsed_json = ActiveSupport::JSON.decode(default_resources)

    if current_acl.present?
      parsed_json.map {|x| x['children'].map {|y|
        if current_acl.include? y['id'].to_s
          y['checked'] = true
        end; y['text'] = y['text'].titleize}; x['text'] = x['text'].titleize}
    else
      parsed_json.map {|x| x['children'].map {|y| y['text'] = y['text'].titleize}; x['text'] = x['text'].titleize}
    end

    render json: parsed_json.to_json
    # authorize_acl :overseer
  end

  def get_menu_resources
    default_resources = get_acl_menu_resource_json
    current_acl = ActiveSupport::JSON.decode(@overseer.acl_resources)
    parsed_json = ActiveSupport::JSON.decode(default_resources)

    if current_acl.present?
      parsed_json.map {|x| x['children'].map {|y|
        # raise
        if current_acl.include? y['id'].to_s
          y['checked'] = true
        end; y['text'] = y['text'].titleize}; x['text'] = x['text'].titleize}
    else
      parsed_json.map {|x| x['children'].map {|y| y['text'] = y['text'].titleize}; x['text'] = x['text'].titleize}
    end

    render json: parsed_json.to_json
    # authorize_acl :overseer
  end

  def save_acl_resources
    authorize_acl @overseer
    @overseer.update_attribute(:acl_resources, params[:checkedIds].to_json)
    render json: {'acl_resources' => @overseer.acl_resources}
  end

  def isp_report
    authorize_acl :overseer
    service = Services::Overseers::Finders::IspReport.new(params, current_overseer)
    service.call
    records = service.records
    @overseers = Inquiry.procurement_specialists
    report_bucket_service = Services::Overseers::Overseers::GetIspReportBuckets.new(records, @overseers, params)
    @per = (params['per'] || params['length'] || 20).to_i
    @page = params['page'] || ((params['start'] || 20).to_i / @per + 1)
    bucket_records = report_bucket_service.call
    @records = Kaminari.paginate_array(bucket_records).page(@page).per(@per)
    if params['isp_report'].present?
      @date_range = params['isp_report']['date_range']
    end
  end

  def export_isp_report
    authorize_acl :overseer
    service = Services::Overseers::Finders::IspReport.new(params, current_overseer)
    service.call
    records = service.records
    @overseers = Inquiry.procurement_specialists

    report_bucket_service = Services::Overseers::Overseers::GetIspReportBuckets.new(records, @overseers, params)
    indexed_isp_reports = report_bucket_service.call
    if params['isp_report'].present?
      @date_range = params['isp_report']['date_range']
      @category = params['isp_report']['category']
    end
    isp_params = {}
    if params['isp_report'].present?
      isp_params['date_range'] = params['isp_report']['date_range']
    else
      isp_params['date_range'] = 'Overall'
    end

    export_service = Services::Overseers::Exporters::IspReportsExporter.new([], current_overseer, indexed_isp_reports, isp_params)
    export_service.call

    redirect_to url_for(Export.isp_reports.not_filtered.last.report)
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
          :acl_role,
          :is_super_admin
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
