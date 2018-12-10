class Overseers::CompaniesController < Overseers::BaseController
  before_action :set_company, only: [:show]

  def index
    @companies = ApplyDatatableParams.to(Company.all.includes(:contacts, :account, :addresses, :inquiries), params)
    authorize @companies
  end

  def autocomplete
    @companies = ApplyParams.to(Company.all.where(:is_active => true), params)
    authorize @companies
  end

  def show
    authorize @company
  end

  def export_all
    authorize :inquiry
    service = Services::Overseers::Exporters::CompaniesExporter.new
    service.call

    redirect_to url_for(Export.companies.last.report)
  end

  private
  def set_company
    @company ||= Company.find(params[:id])
  end
end
