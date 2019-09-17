# frozen_string_literal: true

class Suppliers::CompaniesController < Suppliers::BaseController
  def choose_company
    @contact = current_contact
    if current_contact.companies.size <= 1
      session[:current_company_id] = current_contact.companies.first.id
      redirect_to suppliers_dashboard_path
    else
      render 'shared/layouts/choose_company'
    end
    authorize @contact
  end

  def contact_companies
    @companies = ApplyParams.to(current_contact.companies, params)
    authorize @companies
  end
end
