# frozen_string_literal: true

class Customers::SignInStepsController < Customers::BaseController
  before_action :set_contact, only: %i[reset_current_company edit_current_company update_current_company]

  def reset_current_company
    authorize @contact
    session[:current_company_id] = nil
    redirect_back fallback_location: customers_dashboard_path
  end

  def edit_current_company
    authorize @contact

    if @contact.companies.size == 1
      session[:current_company_id] = @contact.companies.first.id
      redirect_to customers_dashboard_path
    end
  end

  def update_current_company
    authorize @contact
    session[:current_company_id] = contact_params[:company_id]
    redirect_to customers_dashboard_path
  end

  private

    def contact_params
      params.require(:contact).permit(
        :company_id
      )
    end

    def set_contact
      @contact = current_contact
    end
end
