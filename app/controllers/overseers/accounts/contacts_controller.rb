class Overseers::Accounts::ContactsController < Overseers::Accounts::BaseController
  before_action :set_contact, only: [:edit, :update]

  def new
    @contact = @account.contacts.build(overseer: current_overseer)
    authorize @contact
  end

  def create
    @contact = @account.contacts.build(contact_params.merge(overseer: current_overseer))
    authorize @contact

    if @contact.save
      redirect_to overseers_account_path(@account), notice: flash_message(@contact, action_name)
    else
      render :new
    end
  end

  def edit
    authorize @contact
  end

  def update
    @contact.assign_attributes(contact_params.merge(overseer: current_overseer).reject! { |_, v| v.blank? })
    authorize @contact

    if @contact.save
      redirect_to overseers_account_path(@account), notice: flash_message(@contact, action_name)
    else
      render :new
    end
  end

  private
  def set_contact
    @contact ||= Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
        :account_id,
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :company_ids => []
    )
  end
end
