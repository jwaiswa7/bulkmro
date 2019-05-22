class Overseers::OverseersController < Overseers::BaseController
  before_action :set_overseer, only: [:edit, :update, :save_acl_resources, :get_resources, :edit_acl, :update_acl]

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

  def edit
    # authorize_acl @overseer
    authorize_acl @overseer
  end

  def edit_acl
    authorize @overseer
  end

  def update_acl

    begin
      acl_role = AclRole.find(params[:acl_role_id])
      if acl_role.present?
        @overseer.update_attribute(:acl_resources, params[:checkedIds].to_json)
        @overseer.update_attribute(:acl_role_id, acl_role.id)
        render json: {success:1, message: 'Updated successfully.'}
      else
        render json: {success:0, message: 'Role not found.'}
      end
    rescue StandardError => e
      render json: {success:0, message: e}
    end

    authorize_acl :overseer
    #
    # if @overseer.save_and_sync
    #   acl_role = AclRole.find(params[:acl_role_id])
    #   @overseer.update_attributes(:acl_resources => acl_role.role_resources) if acl_role.present?
    #   redirect_to overseers_overseers_path, notice: flash_message(@overseer, action_name)
    # else
    #   render 'edit_acl'
    # end
  end

  def update
    @overseer.assign_attributes(overseer_params.merge(overseer: current_overseer).reject! { |k, v| (k == 'password' || k == 'password_confirmation') && v.blank? })
    authorize_acl @overseer
    if @overseer.save_and_sync
      acl_role = AclRole.find(params[:overseer][:acl_role_id])
      @overseer.update_attributes(:acl_resources => acl_role.role_resources) if acl_role.present?
      redirect_to overseers_overseers_path, notice: flash_message(@overseer, action_name)
    else
      render 'edit'
    end
  end

  def get_resources

    default_resources = Settings.acl.default_resources
    current_acl = @overseer.acl_resources
    parsed_json = ActiveSupport::JSON.decode(default_resources)
    parsed_json.map{|x| x['children'].map{|y| if current_acl.include? y['id'].to_s;y['checked'] = true;end; y['text'] = y['text'].titleize }; x['text'] = x['text'].titleize } if current_acl.present?

    render json: parsed_json.to_json
    # authorize_acl :overseer
  end

  def save_acl_resources
    authorize_acl @overseer
    @overseer.update_attribute(:acl_resources, params[:checkedIds].to_json)
    render json: {'acl_resources' => @overseer.acl_resources}
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
          :acl_role
      )
    end

    def set_overseer
      @overseer = Overseer.find(params[:id])
    end
end
