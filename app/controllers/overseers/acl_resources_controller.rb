class Overseers::AclResourcesController < Overseers::BaseController
  before_action :set_acl_resource, only: [:show, :edit, :update, :destroy]

  def index
    @acl_resources = ApplyDatatableParams.to(AclResource.all, params)
    authorize_acl @acl_resources
  end

  def show
    authorize_acl @acl_resource
  end

  def new
    @acl_resource = AclResource.new(overseer: current_overseer)
    authorize_acl @acl_resource
  end

  def create
    @acl_resource = AclResource.new(acl_resource_params.merge(overseer: current_overseer))

    authorize_acl @acl_resource
    if @acl_resource.save
      redirect_to overseers_acl_resource_path(@acl_resource), notice: flash_message(@acl_resource, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize_acl @acl_resource
  end

  def destroy
    authorize_acl @acl_resource
    if @acl_resource.delete
      redirect_to overseers_acl_resources_path, notice: flash_message(@acl_resource, action_name)
    else
      render 'index'
    end
  end

  def update
    @acl_resource.assign_attributes(acl_resource_params.merge(overseer: current_overseer))
    authorize_acl @acl_resource
    if @acl_resource.save
      redirect_to overseers_acl_resource_path(@acl_resource), notice: flash_message(@acl_resource, action_name)
    else
      render 'edit'
    end
  end

  def menu_resource_json
    refresh_acl_menu_resource_json
    render json: Rails.cache.fetch('acl_menu_resource_json')
  end

  def resource_json
    refresh_acl_resource_json
    render json: Rails.cache.fetch('acl_resource_json')
    # authorize_acl :acl_resource
  end


  def refresh_acl_resource_json
    refresh_acl_menu_resource_json
    refresh_acl_resource_ids

    Rails.cache.delete('acl_resource_json')
    Rails.cache.fetch('acl_resource_json', expires_in: 3.hours) do
      AclResource.acl_resource_json
    end
  end

  def refresh_acl_menu_resource_json
    Rails.cache.delete('acl_menu_resource_json')
    Rails.cache.fetch('acl_menu_resource_json', expires_in: 3.hours) do
      AclResource.acl_menu_resource_json
    end
  end

  def refresh_acl_resource_ids
    Rails.cache.delete('acl_resource_ids')
    Rails.cache.fetch('acl_resource_ids', expires_in: 3.hours) do
      AclResource.acl_resource_ids
    end
  end

  private

  def acl_resource_params
    params.require(:acl_resource).permit(
        :resource_model_name,
        :resource_model_alias,
        :resource_action_name,
        :resource_action_alias,
        :sort_order,
        :is_menu_item
    )
  end

  def set_acl_resource
    @acl_resource = AclResource.find(params[:id])
  end

end