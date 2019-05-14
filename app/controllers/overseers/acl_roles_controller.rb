class Overseers::AclRolesController < Overseers::BaseController
  before_action :set_acl_role, only: [:edit, :update, :get_acl]

  def index
    @acl_roles = ApplyDatatableParams.to(AclRole.all, params)
    authorize_acl @acl_roles
  end

  def new
    @acl_role = acl_role.new(acl_role: current_acl_role)
    authorize_acl @acl_role
  end

  def create
    @acl_role = acl_role.new(acl_role_params.merge(acl_role: current_acl_role, password: password, password_confirmation: password))
    authorize_acl @acl_role
    if @acl_role.save_and_sync
      redirect_to acl_roles_acl_roles_path, notice: flash_message(@acl_role, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize_acl @acl_role
  end

  def update
    authorize_acl @acl_role
    begin
      if @acl_role.present?
        @acl_role.update_attribute(:role_resources, params[:checkedIds].to_json)
        render json: {success:1, message: 'Updated successfully.'}
      else
        render json: {success:0, message: 'Role not found.'}
      end
    rescue StandardError => e
      render json: {success:0, message: e}
    end
  end

  def get_acl
    default_resources = Settings.acl.default_resources
    current_acl = @acl_role.role_resources
    parsed_json = ActiveSupport::JSON.decode(default_resources)
    parsed_json.map{|x| x['children'].map{|y| if current_acl.include? y['id'].to_s;y['checked'] = true;end; y['text'] = y['text'].titleize }; x['text'] = x['text'].titleize }
    render json: parsed_json.to_json
    authorize_acl @acl_role
  end

  private

    def acl_role_params
      params.require(:acl_role).permit(
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

    def set_acl_role
      @acl_role = AclRole.find(params[:id])
    end
end
