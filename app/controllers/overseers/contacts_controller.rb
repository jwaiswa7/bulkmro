class Overseers::ContactsController < Overseers::BaseController
  before_action :set_contact, only: [:show, :edit, :update, :become]

  def index
    # service = Services::Overseers::Finders::Contacts.new(params)
    # service.call
    # @indexed_contacts = service.indexed_records
    # @contacts = service.records
    # authorize @contacts

    @contacts = ApplyDatatableParams.to(Contact.all.includes(:companies), params)
    authorize @contacts
  end

  def autocomplete
    @contacts = ApplyParams.to(Contact.active, params)
    authorize @contacts
  end

  def show
    authorize @contact
  end

  def new
    @company = Company.find(params[:company_id])
    @contact = @company.contacts.build(overseer: current_overseer, account: @company.account)
    authorize @contact
  end

  def create
    @company = Company.find(params[:company_id])
    password = Devise.friendly_token[0, 20]
    @contact = @company.contacts.build(contact_params.merge(account: @company.account, overseer: current_overseer, password: password, password_confirmation: password))
    authorize @contact

    if @contact.save_and_sync
      @company.update_attributes(:default_company_contact => @contact.company_contact) if @company.default_company_contact.blank?
      redirect_to overseers_company_path(@company), notice: flash_message(@contact, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @contact
  end

  def update
    @contact.assign_attributes(contact_params.merge(overseer: current_overseer).reject! {|k, v| (k == 'password' || k == 'password_confirmation') && v.blank?})
    authorize @contact

    if @contact.save_and_sync
      redirect_to overseers_account_path(@contact.account), notice: flash_message(@contact, action_name)
    else
      render 'edit'
    end
  end

  def become
    authorize @contact
    sign_in(:contact, @contact)
    redirect_to customers_dashboard_url(became: true)
  end

  private

  def set_contact
    @contact ||= Contact.find(params[:id])
    @inquiries = @contact.inquiries
  end

  def contact_params
    params.require(:contact).permit(
        :company_id,
        :first_name,
        :last_name,
        :legacy_email,
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
        :is_active,
        :company_ids => []
    )
  end
end