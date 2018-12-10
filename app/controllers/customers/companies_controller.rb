class Customers::CompaniesController < Customers::BaseController
  def choose_company
    @@current_company = nil
    @contact = current_contact
    authorize @contact
    render 'shared/layouts/choose_company'
  end

  def contact_companies
    @companies = ApplyParams.to(current_contact.companies, params)
    authorize @companies
  end
end