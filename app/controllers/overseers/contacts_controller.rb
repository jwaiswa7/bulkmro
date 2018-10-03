class Overseers::ContactsController < Overseers::BaseController
  before_action :set_contact, only: [:show, :edit, :update]

  def index
    @contacts = ApplyDatatableParams.to(Contact.all.includes(:companies), params)
    authorize @contacts
  end

  def autocomplete
    @contacts = ApplyParams.to(Contact.all, params)
    authorize @contacts
  end

  def show
    redirect_to edit_overseers_company_contact_path(@company, @contact)
    authorize @contact
  end

  def new
    @company = Company.find(params[:company_id])
    @contact = @company.contacts.build(overseer: current_overseer)
    authorize @contact
  end

  def create
    @company = Company.find(params[:company_id])
    @contact = @company.contacts.build(contact_params.merge(account: @company.account, overseer: current_overseer))
    authorize @contact

    if @contact.save
      redirect_to overseers_company_path(@company), notice: flash_message(@contact, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @contact
  end

  def update
    @contact.assign_attributes(contact_params.merge(overseer: current_overseer).reject! { |_, v| v.blank? })
    authorize @contact

    if @contact.save
      redirect_to :back, notice: flash_message(@contact, action_name)
    else
      render 'edit'
    end
  end

  private
  def set_contact
    @contact ||= Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
        :company_id,
        :first_name,
        :last_name,
        :password,
        :password_confirmation,
        :prefix,
        :designation,
        :telephone,
        :mobile,
        :email,
        :role,
        :status,
        :contact_group,
        :company_ids => []
    )
  end

end