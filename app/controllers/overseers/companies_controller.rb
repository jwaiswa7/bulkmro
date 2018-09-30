class Overseers::CompaniesController < Overseers::BaseController
  before_action :set_company, only: [:show]

  def index
    @companies = ApplyDatatableParams.to(Company.all.includes(:contacts, :account, :addresses, :inquiries), params)
    authorize @companies
  end

  def autocomplete
    @companies = ApplyParams.to(Company.all, params)
    authorize @companies
  end

  def show
    authorize @company
  end

  private
  def set_company
    @company ||= Company.find(params[:id])
  end
end
