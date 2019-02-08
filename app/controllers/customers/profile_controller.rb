class Customers::ProfileController < Customers::BaseController
  before_action :authenticate_contact!

  def edit
    @contact = current_contact
    authorize :profile
  end

  def update
    authorize :profile
    @contact = current_contact
    @contact.assign_attributes(profile_params)
    if @contact.update_with_password(profile_params)
      redirect_to edit_customers_profile_path, notice: flash_message(@contact, action_name)
    else
      render 'edit'
    end
  end

  private

  def profile_params
    params.require(:contact).permit(
        :first_name,
        :last_name,
        :email,
        :current_password,
        :password,
        :password_confirmation
    )
  end
end