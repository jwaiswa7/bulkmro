# frozen_string_literal: true

class Customers::CompaniesController < Customers::BaseController
  def choose_company
    @contact = current_customers_contact
    if @contact.companies.size <= 1
      session[:current_company_id] = @contact.companies.first.id
      redirect_to customers_dashboard_path
    else
      render 'shared/layouts/choose_company'
    end
    authorize @contact
  end

  def contact_companies
    @companies = ApplyParams.to(current_customers_contact.companies, params)
    authorize @companies
  end
end
