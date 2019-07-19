class Overseers::ContactCreationRequestsController < Overseers::BaseController
  before_action :set_contact_creation_request, only: [:show, :update]

  def requested
    @contact_creation_requests = ApplyDatatableParams.to(ContactCreationRequest.all.requested.order(id: :desc), params)
    authorize_acl @contact_creation_requests
    respond_to do |format|
      format.json { render 'index' }
      format.html { render 'index' }
    end
  end

  def created
    @contact_creation_requests = ApplyDatatableParams.to(ContactCreationRequest.all.created.order(id: :desc), params)
    authorize_acl @contact_creation_requests
    respond_to do |format|
      format.json { render 'index' }
      format.html { render 'index' }
    end
  end

  def update
    authorize_acl @contact_creation_request
    contact = Contact.where(id: params[:contact_creation_request][:contact_id]).last
    @contact_creation_request.activity.update_attributes!(contact_id: params[:contact_id]) if @contact_creation_request.activity.present?
    @contact_creation_request.update_attributes(contact: contact)
    redirect_to overseers_contact_creation_request_path(@contact_creation_request), notice: flash_message(@contact_creation_request, action_name)
  end

  def index
    @contact_creation_requests = ApplyDatatableParams.to(ContactCreationRequest.all.order(id: :desc), params)
    authorize_acl @contact_creation_requests
  end

  def show
    authorize_acl @contact_creation_request
  end

  private

    def set_contact_creation_request
      @contact_creation_request ||= ContactCreationRequest.find(params[:id])
    end
end
