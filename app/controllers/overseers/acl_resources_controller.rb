class Overseers::AclResourcesController < Overseers::BaseController
  before_action :set_acl_resource, only: [:show, :edit, :update]

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

    end

    redirect_to overseers_acl_resource_path(@acl_resource), notice: flash_message(@acl_resource, action_name)
  else
    render 'new'
  end

  def edit
    authorize_acl @acl_resource
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

  def resource_json
    resource_json = {}
    AclResource.all.each do |acl_resource|
      resource_json[acl_resource.resource_model_name]
    end
  end

  private

  def acl_resource_params
    params.require(:acl_resource).permit(
        :resource_model_name,
        :resource_model_name
    )
  end

  def set_acl_resource
    @acl_resource = AclResource.find(params[:id])
  end

end