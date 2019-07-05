class Overseers::AclRolesController < Overseers::BaseController
  before_action :set_acl_role, only: [:edit, :update, :get_acl, :get_acl_menu, :get_role_resources]

  def index
    @acl_roles = ApplyDatatableParams.to(AclRole.all, params)
    authorize_acl @acl_roles
  end

  def new
    @acl_role = AclRole.new(overseer: current_overseer)
    authorize_acl @acl_role
  end

  def create
    # authorize_acl @acl_role
    @acl_role = AclRole.new(acl_role_params.merge(overseer: current_overseer))

    if @acl_role.save
      redirect_to edit_overseers_acl_role_path(@acl_role), notice: flash_message(@acl_role, action_name)
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
        checked_ids = params[:checked_ids]
        menu_checked_ids = params[:menu_checked_ids]
        checked_ids = checked_ids + menu_checked_ids
        @acl_role.update_attribute(:role_resources, checked_ids.uniq.to_json)
        @acl_role.update_attribute(:is_default, params[:is_default])
<<<<<<< HEAD
=======
        @acl_role.update_attribute(:updated_by, current_overseer)
>>>>>>> 9b9b9e6e2fe602351e784691b108e1a7c3fb3753

        #update overseer resources
        Overseer.where(acl_role: @acl_role).each do |overseer|
          overseer_resources = ActiveSupport::JSON.decode(overseer.acl_resources)
          new_resources = overseer_resources + ActiveSupport::JSON.decode(@acl_role.role_resources)
          overseer.update_attribute(:acl_resources, new_resources.uniq.to_json)
        end

        success = 1
        message = 'Updated successfully.'
      else
        success = 0
        message = 'Role not found.'
      end
    rescue StandardError => e
      success = 0
      message = e
    end

    render json: {success:success, message: message}
  end

  def get_acl
    default_resources = get_acl_resource_json
    current_acl = ActiveSupport::JSON.decode(@acl_role.role_resources)
    parsed_json = ActiveSupport::JSON.decode(default_resources)
    parsed_json.map{|x| x['children'].map{|y|
        if current_acl.present? && (current_acl.include?y['id'].to_s)
          y['checked'] = true
        end
        y['text'] = y['text'].titleize
      }
      x['text'] = x['text'].titleize
    }
    render json: parsed_json.to_json
    authorize_acl @acl_role
  end

  def get_acl_menu
    default_resources = get_acl_menu_resource_json
    current_acl = ActiveSupport::JSON.decode(@acl_role.role_resources)
    parsed_json = ActiveSupport::JSON.decode(default_resources)

    parsed_json.map{|x| x['children'].map{|y|
      if current_acl.present? && (current_acl.include?y['id'].to_s)
        y['checked'] = true
      end
      y['text'] = y['text'].titleize
    }
    x['text'] = x['text'].titleize
    }
    render json: parsed_json.to_json
    # authorize_acl @acl_role
  end

  def get_role_resources
    parsed_json = ActiveSupport::JSON.decode(@acl_role.role_resources)
    parsed_json.sort_by {|k,v| v}.reverse
    render json: parsed_json.to_json
    # authorize_acl @acl_role
  end

  def get_default_resources
    default_resources = Settings.acl.default_resources
    parsed_json = ActiveSupport::JSON.decode(default_resources)
    parsed_json.map{|x| x['children'].map{|y| y['text'] = y['text'].titleize }; x['text'] = x['text'].titleize }
    render json: parsed_json.to_json
  end

  private

    def acl_role_params
      params.require(:acl_role).permit(
        :role_name
      )
    end

    def set_acl_role
      @acl_role = AclRole.find(params[:id])
    end
end
