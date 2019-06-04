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

  def resource_json
    resource_json = []
    models = []
    children = []
    acl_parent = []
    Rails.cache.delete('acl_resource_json')
    Rails.cache.fetch('acl_resource_json', expires_in: 3.hours) do

      AclResource.all.order(resource_model_name: :asc).each do |acl_resource|
        if !models.include? acl_resource.resource_model_name
          if children.present? && children.size > 0
            acl_parent.children = children
            resource_json.push(acl_parent.marshal_dump)
            children = []
          end

          models << acl_resource.resource_model_name

          #Parent Node
          acl_parent = OpenStruct.new
          acl_parent.id = acl_resource.id
          acl_parent.text = acl_resource.resource_model_name
          acl_parent.checked = false
          acl_parent.hasChildren = true

          #First Child Node
          acl_row = OpenStruct.new
          acl_row.id = acl_resource.id
          acl_row.text = acl_resource.resource_action_name
          acl_row.checked = false
          acl_row.hasChildren = false
          children.push(acl_row.marshal_dump)
        else
          acl_row = OpenStruct.new
          acl_row.id = acl_resource.id
          acl_row.text = acl_resource.resource_action_name
          acl_row.checked = false
          acl_row.hasChildren = false
          children.push(acl_row.marshal_dump)
        end
      end

      #Last child node
      if children.present? && children.size > 0
        acl_parent.children = children
        resource_json.push(acl_parent.marshal_dump)
        children = []
      end

      resource_json.to_json
    end

    render json: Rails.cache.fetch('acl_resource_json')
    # authorize_acl :acl_resource
  end

  private

  def acl_resource_params
    params.require(:acl_resource).permit(
        :resource_model_name,
        :resource_action_name
    )
  end

  def set_acl_resource
    @acl_resource = AclResource.find(params[:id])
  end

end